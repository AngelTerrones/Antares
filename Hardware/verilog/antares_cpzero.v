//==================================================================================================
//  Filename      : antares_cpzero.v
//  Created On    : Sat Sep  5 18:48:44 2015
//  Last Modified : Sat Nov 07 11:59:09 2015
//  Revision      : 1.0
//  Author        : Angel Terrones
//  Company       : Universidad Simón Bolívar
//  Email         : aterrones@usb.ve
//
//  Description   : The Coprocessor 0 (CP0)
//                  This module allows interrupts; traps, system calls and other exceptions.
//                  No Virtual Memory management
//                  Only a subset of CP0 (MIPS32 compliant).
//==================================================================================================

`include "antares_defines.v"

module antares_cpzero (
                       input             clk,
                       // CP0
                       input             mfc0,                 // mfc0 instruction
                       input             mtc0,                 // mtc0 instruction
                       input             eret,                 // eret instruction
                       input             cp1_instruction,      // Instruction for co-processor 1 (invalid for now)
                       input             cp2_instruction,      // Instruction for co-processor 2 (invalid for now)
                       input             cp3_instruction,      // Instruction for co-processor 3 (invalid for now)
                       input [4:0]       register_address,     // CP0 Register
                       input [2:0]       select,               // Select register
                       input [31:0]      data_input,           // Input data (write)
                       input             if_stall,             // Can not write to CP0 if IF/ID is stalled
                       input             id_stall,             // Can not write to CP0 if IF/ID is stalled
                       output reg [31:0] cp0_data_output,      // Output data (read)
                       output            id_kernel_mode,       // Kernel mode: 0 Kernel, 1 User
                       // Hardware/External Interrupts
                       input [4:0]       interrupts,           // Up to 5 external interrupts
                       // exceptions
                       input             rst,                  // External reset
                       input             exc_nmi,              // Non-maskable interrupt
                       input             exc_address_if,       // Address error: IF stage
                       input             exc_address_l_mem,    // Address error: MEM stage, load instruction
                       input             exc_address_s_mem,    // Address error: MEM stage, store instruction
                       input             exc_ibus_error,       // Instruction Bus Error
                       input             exc_dbus_error,       // Data Bus Error
                       input             exc_overflow,         // Integer overflow: EX stage
                       input             exc_trap,             // Trap exception
                       input             exc_syscall,          // System call
                       input             exc_breakpoint,       // Breakpoint
                       input             exc_reserved,         // Reserved Instruction
                       // exception data
                       input [31:0]      id_exception_pc,      // Exception PC @ ID stage
                       input [31:0]      ex_exception_pc,      // Exception PC @ EX stage
                       input [31:0]      mem_exception_pc,     // Exception PC @ MEM stage
                       input [31:0]      bad_address_if,       // Bad address that caused the exception
                       input [31:0]      bad_address_mem,      // Bad address that caused the exception
                       input             id_exception_source,  // Instruction @ ID stage is a potential source of exception
                       input             ex_exception_source,  // Instruction @ EX stage is a potential source of exception
                       input             mem_exception_source, // Instruction @ MEM stage is a potential source of exception
                       input             id_is_flushed,        // BDS for ERET instruction
                       input             if_is_bds,            // Instruction at this stage is a Branch Delay Slot
                       input             id_is_bds,            // Instruction at this stage is a Branch Delay Slot
                       input             ex_is_bds,            // Instruction at this stage is a Branch Delay Slot
                       input             mem_is_bds,           // Instruction at this stage is a Branch Delay Slot
                       // pipeline control
                       output            halt,                 // Halt the processor.
                       output            if_exception_stall,   // Stall pipeline: exception and wait for a clean pipeline
                       output            id_exception_stall,   // Stall pipeline: exception and wait for a clean pipeline
                       output            ex_exception_stall,   // Stall pipeline: exception and wait for a clean pipeline
                       output            mem_exception_stall,  // Stall pipeline: exception and wait for a clean pipeline
                       output            if_flush,             // Flush the pipeline: exception.
                       output            id_flush,             // Flush the pipeline: exception.
                       output            ex_flush,             // Flush the pipeline: exception.
                       output            mem_flush,            // Flush the pipeline: exception.
                       output            exception_ready,
                       output            exception_pc_select,  // Select the PC from CP0
                       output reg [31:0] pc_exception          // Address for the new PC (exception/return from exception)
                       );

    //--------------------------------------------------------------------------
    // Internal wires/registers
    //--------------------------------------------------------------------------
    wire              exception_cp;            // Unusable co-processor
    wire              interrupt_5;             // Hardware interrupt #5: Count/Compare (timer)
    wire              interrupt_enabled;       // Interrupt?
    wire              exception_interrupt;     // The interrupt is OK to process.
    wire              cp0_enable_write;        // Write to CP0 is OK (no hazards)
    wire              exception_no_interrupts; // All exceptions, but Interrupts, Reset, Soft-Reset, NMI

    reg [4:0]         cause_ExcCode_aux;       // Hold the ExcCode (?)

    wire              if_exception;            // exceptions by stage
    wire              id_exception;            // exceptions by stage
    wire              ex_exception;            // exceptions by stage
    wire              mem_exception;           // exceptions by stage

    wire              if_exception_mask;       // enable exception at this stage
    wire              id_exception_mask;       // enable exception at this stage
    wire              ex_exception_mask;       // enable exception at this stage
    wire              mem_exception_mask;      // enable exception at this stage

    wire              if_exception_ready;      // ready to process
    wire              id_exception_ready;      // ready to process
    wire              ex_exception_ready;      // ready to process
    wire              mem_exception_ready;     // ready to process

    //--------------------------------------------------------------------------
    // CP0 Registers
    // Defined in "MIPS32 Architecture for Programmers Volume III:
    // The MIPS32 Privileged Resource Architecture" by Imagination Technologies, LTD.
    // Only a subset.
    //--------------------------------------------------------------------------
    // Status Register:
    wire    [2:0]   Status_CU_321 = 3'b000;                 // Access Control to CPs, [2]->Cp3, ... [0]->Cp1
    reg             Status_CU_0;                            // Access Control to CP0
    wire            Status_RP     = 0;
    wire            Status_FR     = 0;
    wire            Status_RE     = 0;                      // Reverse Endian Memory for User Mode
    wire            Status_MX     = 0;
    wire            Status_PX     = 0;
    reg             Status_BEV;                             // Exception vector locations (0->Norm, 1->Bootstrap)
    wire            Status_TS     = 0;
    wire            Status_SR     = 0;                      // Soft reset (Not implemented)
    reg             Status_NMI;                             // Non-Maskable Interrupt
    wire    [1:0]   Status_RES    = 0;                      // Reserved.
    reg             Status_HALT;                            // Stop processor
    reg     [7:0]   Status_IM;                              // Interrupt mask
    wire            Status_KX     = 0;                      // 64-bits mode. (Not implemented)
    wire            Status_SX     = 0;                      // 64-bits mode. (Not implemented)
    wire            Status_UX     = 0;                      // 64-bits mode. (Not implemented)
    reg     [1:0]   Status_KSU;                             // CPU privileged level: 0 -> kernel, 1 -> supervisor, 2 -> user
    reg             Status_ERL;                             // Error Level     (0->Normal, 1->Error (reset, NMI))
    reg             Status_EXL;                             // Exception level (0->Normal, 1->Exception)
    reg             Status_IE;                              // Interrupt Enable
    wire    [31:0]  Status;                                 // Status Register (Register 12, Select 0)

    // Cause Register:
    reg             Cause_BD;                               // Exception at BDS
    reg     [1:0]   Cause_CE;                               // Co-processor error: Unusable co-processor
    reg             Cause_IV;                               // Special exception entry point
    wire            Cause_WP = 0;                           // Enable watchpoint exception mode.
    reg     [7:0]   Cause_IP;                               // Pending hardware interrupts
    reg     [4:0]   Cause_ExcCode;                          // Exception code.
    wire    [31:0]  Cause;                                  // Cause Register (Register 13, Select 0)

    // Processor Identification:
    wire    [7:0]   ID_Options = 8'b0000_0000;              // Company Options -> to define
    wire    [7:0]   ID_CID     = 8'b0000_0000;              // Company ID -> to zero
    wire    [7:0]   ID_PID     = 8'b0000_0000;              // CPU ID
    wire    [7:0]   ID_Rev     = 8'b0000_0001;              // Revision
    wire    [31:0]  PRId;                                   // Processor ID (Register 15, Select 0)

    // Configuration Register:
    wire            Config_M    = 1;                        // Continuation bit. 1-> if another config register is available
    wire    [14:0]  Config_Impl = 15'b000_0000_0000_0000;   // Implementation-dependent configuration flags.
    wire            Config_BE   = `ANTARES_LITTLE_ENDIAN;   // Endiannes
    wire    [1:0]   Config_AT   = 2'b00;                    // MIPS32
    wire    [2:0]   Config_AR   = 3'b000;                   // MIPS32 Release 1
    wire    [2:0]   Config_MT   = 3'b000;                   // MMU -> none
    wire            Config_VI   = 1'b0;                     // L1 I-cache do not use virtual address
    wire    [2:0]   Config_K0   = 3'b000;                   // Fixed kseg0 region is cached or uncached? behavior?
    wire    [31:0]  Config;                                 // Config Register (Register 16, Select 0)

    // Configuration Register 1:
    wire            Config1_M   = 0;                        // Continuation bit
    wire    [5:0]   Config1_MMU = 6'b000000;                // MMU size
    wire    [2:0]   Config1_IS  = 3'b000;                   // Number of index positions: 64 x 2^S
    wire    [2:0]   Config1_IL  = 3'b000;                   // 0 -> no cache. Else: 2^(L + 1)
    wire    [2:0]   Config1_IA  = 3'b000;                   // Associativity -> (A + 1)
    wire    [2:0]   Config1_DS  = 3'b000;                   // Number of index positions: 64 x 2^S
    wire    [2:0]   Config1_DL  = 3'b000;                   // 0 -> no cache. Else: 2^(L + 1)
    wire    [2:0]   Config1_DA  = 3'b000;                   // Associativity -> (A + 1)
    wire            Config1_C2  = 0;                        // Co-processor 2?
    wire            Config1_MD  = 0;                        // MDMX ASE?
    wire            Config1_PC  = 0;                        // Performance Counters ?
    wire            Config1_WR  = 0;                        // Watch Registers ?
    wire            Config1_CA  = 0;                        // MIPS16?
    wire            Config1_EP  = 0;                        // EJTAG?
    wire            Config1_FP  = 0;                        // Floating-point?
    wire    [31:0]  Config1;                                // Config Register (Register 16, Select 1)

    reg     [31:0]  BadVAddr;                               // BadVAddr Register (Register 8, Select 0)
    reg     [31:0]  Count;                                  // Count Register (Register 9, Select 0)
    reg     [31:0]  Compare;                                // Compare Register (Register 11, Select 0)
    reg     [31:0]  EPC;                                    // Exception Program Counter (Register 14, Select 0)
    reg     [31:0]  ErrorEPC;                               // Error Register (Register 30, Select 0)

    //--------------------------------------------------------------------------
    // assignments
    //--------------------------------------------------------------------------
    assign  Status  = {Status_CU_321, Status_CU_0, Status_RP, Status_FR, Status_RE, Status_MX,           // bits 31-24
                       Status_PX, Status_BEV, Status_TS, Status_SR, Status_NMI, Status_RES, Status_HALT, // bits 23-16
                       Status_IM,                                                                        // bits 15-8
                       Status_KX, Status_SX, Status_UX, Status_KSU, Status_ERL, Status_EXL, Status_IE};  // bits 7-0
    assign  Cause   = {Cause_BD, 1'b0, Cause_CE, 4'b0000,                                                // bits 31-24
                       Cause_IV, Cause_WP, 6'b000000,                                                    // bits 23-16
                       Cause_IP,                                                                         // bits 15-8
                       1'b0, Cause_ExcCode, 2'b0};                                                       // bits 7-0
    assign  PRId    = {ID_Options,                                                                       // bits 31-24
                       ID_CID,                                                                           // bits 23-16
                       ID_PID,                                                                           // bits 15-8
                       ID_Rev};                                                                          // bits 7-0
    assign  Config  = {Config_M, Config_Impl,                                                            // bits 31-16
                       Config_BE, Config_AT, Config_AR, Config_MT,                                       // bits 15-7
                       3'b000, Config_VI, Config_K0};                                                    // bits 6-0
    assign  Config1 = {Config1_M, Config1_MMU,
                       Config1_IS, Config1_IL, Config1_IA,
                       Config1_DS, Config1_DL, Config1_DA,
                       Config1_C2, Config1_MD, Config1_PC, Config1_WR, Config1_CA, Config1_EP, Config1_FP};

    assign exception_cp = cp1_instruction | cp2_instruction | cp3_instruction |                         // Check if the co-processor instruction is valid.
                          ( (mtc0 | mfc0 | eret) & ~(Status_CU_0 | id_kernel_mode) );                      // For CP0   : only if it has been enabled, or in kernel mode, it's ok to use these instructions.
                                                                                                        // For CP3-1 : Always trap.

    assign exception_no_interrupts = exc_address_if | exc_ibus_error | exc_syscall | exc_breakpoint | exc_reserved |    // All exceptions, but interrupts, reset, soft-reset and nmi
                                     exception_cp | exc_overflow | exc_address_l_mem | exc_address_s_mem |              //
                                     exc_dbus_error | exc_trap;                                                         //

    assign id_kernel_mode         = (Status_KSU != 2'b10) | Status_EXL | Status_ERL;                        // Kernel mode if mode != user, Exception level or Error level. To inhibit new exceptions/interrupts
    assign interrupt_5         = (Count == Compare) & Status_IM[7];                                      // Counter interrupt (#5)
    assign interrupt_enabled   = exc_nmi | ( Status_IE & ( (Cause_IP[7:0] & Status_IM[7:0]) != 8'b0 ) ); // Interrupt  if NMI, Interrupts are enabled (global) and the individual interrupt is enable.
    assign exception_interrupt = interrupt_enabled & ~Status_EXL & ~Status_ERL & ~id_is_flushed;         // Interrupt is OK to process if: no exception level and no error level, and the instruction is a forced NOP.
    assign cp0_enable_write    = mtc0 & ~id_stall & (Status_CU_0 | id_kernel_mode) &
                               (~mem_exception & ~ex_exception & ~id_exception & ~if_exception);         // Write to CP0 if ID is not stalled, CP0 is enabled or in kernel mode, and no exceptions
    assign halt                = Status_HALT;

    //--------------------------------------------------------------------------
    // Hazards
    // Rules:
    //  - In case of exception, the stage could be stalled if:
    //      - A forward stage is capable of causing an exception, AND
    //      - A forward stage is not causing an exception.
    //  - An exception is ready to process if not stalled.
    //
    // In case of exception: clear commits, convert to NOP (a.k.a. flush the stage).
    //--------------------------------------------------------------------------

    //--------------------------------------------------------------------------
    // Exceptions by stage
    //--------------------------------------------------------------------------
    assign mem_exception = exc_address_l_mem | exc_address_s_mem | exc_dbus_error | exc_trap;                // Error on load, store, data read, or trap
    assign ex_exception  = exc_overflow;                                                                     // overflow
    assign id_exception  = exc_syscall | exc_breakpoint | exc_reserved | exception_cp | exception_interrupt; // Syscall, breakpoint, reserved instruction, Co-processor or interrupt
    assign if_exception  = exc_address_if | exc_ibus_error;                                                  // Error on load or bus

    //--------------------------------------------------------------------------
    // Mask exception: assert  in case of possible exceptions in forward stages,
    //      or if being stalled.
    // Can not process the exception if IF is stalled (unable to commit the new PC)
    //
    // NOTE: Abort IF operation in case of exception
    //--------------------------------------------------------------------------
    assign mem_exception_mask = 0;
    assign ex_exception_mask  = mem_exception_source;
    assign id_exception_mask  = mem_exception_source | ex_exception_source;
    assign if_exception_mask  = mem_exception_source | ex_exception_source | id_exception_source | exception_interrupt; // In case of interrupt, abort this

    //--------------------------------------------------------------------------
    // Generate the stall signals
    // No writes to CP0 until a clean state (no stalls).
    //--------------------------------------------------------------------------
    assign mem_exception_stall = mem_exception & mem_exception_mask;
    assign ex_exception_stall  = ex_exception & ex_exception_mask & ~mem_exception;
    assign id_exception_stall  = (id_exception | eret | mtc0) & id_exception_mask & ~(mem_exception | ex_exception);
    assign if_exception_stall  = if_exception & if_exception_mask & ~(mem_exception | ex_exception | id_exception);

    //--------------------------------------------------------------------------
    // Signal the valid exception to process
    //--------------------------------------------------------------------------
    assign mem_exception_ready = mem_exception & ~mem_exception_mask;
    assign ex_exception_ready  = ex_exception & ~ex_exception_mask;
    assign id_exception_ready  = id_exception & ~id_exception_mask;
    assign if_exception_ready  = if_exception & ~if_exception_mask;

    //--------------------------------------------------------------------------
    // Flush the stages in case of exception
    //--------------------------------------------------------------------------
    assign mem_flush = mem_exception;
    assign ex_flush  = mem_exception | ex_exception;
    assign id_flush  = mem_exception | ex_exception | id_exception;
    assign if_flush  = mem_exception | ex_exception | id_exception | if_exception | (eret & ~id_stall);       // ERET doest not execute the next instruction!!

    //--------------------------------------------------------------------------
    // Read CP0 registers
    //--------------------------------------------------------------------------
    always @(*) begin
        if(mfc0 & (Status_CU_0 | id_kernel_mode)) begin
            case (register_address)
                5'd8   : cp0_data_output = BadVAddr;
                5'd9   : cp0_data_output = Count;
                5'd11  : cp0_data_output = Compare;
                5'd12  : cp0_data_output = Status;
                5'd13  : cp0_data_output = Cause;
                5'd14  : cp0_data_output = EPC;
                5'd15  : cp0_data_output = PRId;
                5'd16  : cp0_data_output = (select == 3'b000) ? Config : Config1;
                5'd30  : cp0_data_output = ErrorEPC;
                default: cp0_data_output = 32'h0000_0000;
            endcase
        end
        else begin
            cp0_data_output = 32'h0000_0000;
        end
    end

    //--------------------------------------------------------------------------
    // Write CP0 registers.
    // Reset, soft-reset, NMI.
    //--------------------------------------------------------------------------
    always @(posedge clk) begin
        if (rst) begin
            Status_BEV <= 1'b1;
            Status_NMI <= 1'b0;
            Status_ERL <= 1'b1;
            ErrorEPC   <= 32'b0;
        end
        else if (id_exception_ready & exc_nmi) begin
            Status_BEV <= 1'b1;
            Status_NMI <= 1'b1;
            Status_ERL <= 1'b1;
            ErrorEPC   <= id_exception_pc;
        end
        else begin
            Status_BEV <= (cp0_enable_write & (register_address == 5'd12) & (select == 3'b000)) ? data_input[22] : Status_BEV;
            Status_NMI <= (cp0_enable_write & (register_address == 5'd12) & (select == 3'b000)) ? data_input[19] : Status_NMI;
            Status_ERL <= (cp0_enable_write & (register_address == 5'd12) & (select == 3'b000)) ? data_input[2]  : ((Status_ERL & eret & ~id_stall) ? 1'b0 : Status_ERL);
            ErrorEPC   <= (cp0_enable_write & (register_address == 5'd30) & (select == 3'b000)) ? data_input     : ErrorEPC;
        end
    end

    //--------------------------------------------------------------------------
    // Write CP0 registers.
    // Other registers
    //--------------------------------------------------------------------------
    always @(posedge clk) begin
        if (rst) begin
            Count         <= 32'b0;
            Compare       <= 32'b0;
            Status_HALT   <= 1'b0;
            Status_CU_0   <= 1'b0;
            //Status_RE     <= 1'b0;
            Status_IM     <= 8'b0;
            Status_KSU    <= 2'b0;
            Status_IE     <= 1'b0;
            Cause_IV      <= 1'b0;
            Cause_IP      <= 8'b0;
        end
        else begin
            Count         <= (cp0_enable_write & (register_address == 5'd9 ) & (select == 3'b000)) ? data_input       : Count + 1'b1;
            Compare       <= (cp0_enable_write & (register_address == 5'd11) & (select == 3'b000)) ? data_input       : Compare;
            Status_HALT   <= (cp0_enable_write & (register_address == 5'd12) & (select == 3'b000)) ? data_input[16]   : Status_HALT;
            Status_CU_0   <= (cp0_enable_write & (register_address == 5'd12) & (select == 3'b000)) ? data_input[28]   : Status_CU_0;
            //Status_RE     <= (cp0_enable_write & (register_address == 5'd12) & (select == 3'b000)) ? data_input[25]   : Status_RE;
            Status_IM     <= (cp0_enable_write & (register_address == 5'd12) & (select == 3'b000)) ? data_input[15:8] : Status_IM;
            Status_KSU    <= (cp0_enable_write & (register_address == 5'd12) & (select == 3'b000)) ? data_input[4:3]  : Status_KSU;
            Status_IE     <= (cp0_enable_write & (register_address == 5'd12) & (select == 3'b000)) ? data_input[0]    : Status_IE;
            Cause_IV      <= (cp0_enable_write & (register_address == 5'd13) & (select == 3'b000)) ? data_input[23]   : Cause_IV;
            /* Cause_IP indicates 8 interrupts:
               [7]   is set by the timer comparison, and cleared by writing to "Compare".
               [6:2] are set and cleared by external hardware.
               [1:0] are set and cleared by software.
             */
            Cause_IP[7]   <= (cp0_enable_write & (register_address == 5'd11) & (select == 3'b000)) ? 1'b0 : ((Cause_IP[7] == 0) ? interrupt_5 : Cause_IP[7]);    // If reading -> 0, Otherwise if 0 -> interrupt_5.
            Cause_IP[6:2] <= interrupts[4:0];
            Cause_IP[1:0] <= (cp0_enable_write & (register_address == 5'd13) & (select == 3'b000)) ? data_input[9:8] : Cause_IP[1:0];
        end
    end

    //--------------------------------------------------------------------------
    // Write CP0 registers.
    // Exception and Interrupt Processing
    // Ignore if EXL or ERL is asserted
    //--------------------------------------------------------------------------
    always @(posedge clk) begin
        if (rst) begin
            Cause_BD      <= 1'b0;
            Cause_CE      <= 2'b00;
            Cause_ExcCode <= 5'b0;
            Status_EXL    <= 1'b0;
            EPC           <= 32'h0;
            BadVAddr      <= 32'h0;
        end
        else begin
            // MEM stage
            if (mem_exception_ready) begin
                Cause_BD      <= (Status_EXL) ? Cause_BD : mem_is_bds;
                Cause_CE      <= (cp3_instruction) ? 2'b11 : ((cp2_instruction) ? 2'b10 : ((cp1_instruction) ? 2'b01 : 2'b00));
                Cause_ExcCode <= cause_ExcCode_aux;
                Status_EXL    <= 1'b1;
                EPC           <= (Status_EXL) ? EPC : mem_exception_pc;
                BadVAddr      <= bad_address_mem;
            end
            // EX stage
            else if (ex_exception_ready) begin
                Cause_BD      <= (Status_EXL) ? Cause_BD : ex_is_bds;
                Cause_CE      <= (cp3_instruction) ? 2'b11 : ((cp2_instruction) ? 2'b10 : ((cp1_instruction) ? 2'b01 : 2'b00));
                Cause_ExcCode <= cause_ExcCode_aux;
                Status_EXL    <= 1'b1;
                EPC           <= (Status_EXL) ? EPC : ex_exception_pc;
                BadVAddr      <= BadVAddr;
            end
            // ID stage
            else if (id_exception_ready) begin
                Cause_BD      <= (Status_EXL) ? Cause_BD : id_is_bds;
                Cause_CE      <= (cp3_instruction) ? 2'b11 : ((cp2_instruction) ? 2'b10 : ((cp1_instruction) ? 2'b01 : 2'b00));
                Cause_ExcCode <= cause_ExcCode_aux;
                Status_EXL    <= 1'b1;
                EPC           <= (Status_EXL) ? EPC : id_exception_pc;
                BadVAddr      <= BadVAddr;
            end
            // IF stage
            else if (if_exception_ready) begin
                Cause_BD      <= (Status_EXL) ? Cause_BD : if_is_bds;
                Cause_CE      <= (cp3_instruction) ? 2'b11 : ((cp2_instruction) ? 2'b10 : ((cp1_instruction) ? 2'b01 : 2'b00));
                Cause_ExcCode <= cause_ExcCode_aux;
                Status_EXL    <= 1'b1;
                EPC           <= (Status_EXL) ? EPC : bad_address_if;
                BadVAddr      <= bad_address_if;
            end
            // No exceptions this cycle
            else begin
                Cause_BD      <= 1'b0;
                Cause_CE      <= Cause_CE;
                Cause_ExcCode <= Cause_ExcCode;
                // Without new exceptions, 'Status_EXL' is set by software or cleared by ERET.
                Status_EXL    <= (cp0_enable_write & (register_address == 5'd12) & (select == 3'b000)) ? data_input[1] : ((Status_EXL & eret & ~id_stall) ? 1'b0 : Status_EXL);
                // The EPC is also writable by software
                EPC           <= (cp0_enable_write & (register_address == 5'd14) & (select == 3'b000)) ? data_input : EPC;
                BadVAddr      <= BadVAddr;
            end
        end
    end

    //--------------------------------------------------------------------------
    // Set the program counter
    // The PC register handles the reset scenario.
    //--------------------------------------------------------------------------
    always @(*) begin
        if (rst) begin
            pc_exception = `ANTARES_VECTOR_BASE_RESET;
        end
        if (eret & ~id_stall) begin
            pc_exception = (Status_ERL) ? ErrorEPC : EPC;
        end
        else if (exception_no_interrupts) begin
            pc_exception = (Status_BEV) ? (`ANTARES_VECTOR_BASE_BOOT + `ANTARES_VECTOR_OFFSET_GENERAL) : (`ANTARES_VECTOR_BASE_NO_BOOT + `ANTARES_VECTOR_OFFSET_GENERAL);
        end
        else if (exc_nmi) begin
            pc_exception = `ANTARES_VECTOR_BASE_RESET;
        end
        else if (exception_interrupt & Cause_IV) begin
            pc_exception = (Status_BEV) ? (`ANTARES_VECTOR_BASE_BOOT + `ANTARES_VECTOR_OFFSET_SPECIAL) : (`ANTARES_VECTOR_BASE_NO_BOOT + `ANTARES_VECTOR_OFFSET_SPECIAL);
        end
        else begin
            pc_exception = (Status_BEV) ? (`ANTARES_VECTOR_BASE_BOOT + `ANTARES_VECTOR_OFFSET_GENERAL) : (`ANTARES_VECTOR_BASE_NO_BOOT + `ANTARES_VECTOR_OFFSET_GENERAL);
        end
    end

    assign exception_ready     = if_exception_ready | id_exception_ready | ex_exception_ready | mem_exception_ready;
    assign exception_pc_select = rst | (eret & ~id_stall) | exception_ready;

    //--------------------------------------------------------------------------
    // Set the Cause register
    // Ordered by Pipeline Stage with Interrupts last
    //--------------------------------------------------------------------------
    always @(*) begin
        if      (exc_address_l_mem)   cause_ExcCode_aux = 5'h4;     // 00100 (EXC_AdEL)
        else if (exc_address_s_mem)   cause_ExcCode_aux = 5'h5;     // 00101 (EXC_AdES)
        else if (exc_dbus_error)      cause_ExcCode_aux = 5'h7;     // 00111 (EXC_DBE)
        else if (exc_trap)            cause_ExcCode_aux = 5'hd;     // 01101 (EXC_Tr)
        else if (exc_overflow)        cause_ExcCode_aux = 5'hc;     // 01100 (EXC_Ov)
        else if (exc_syscall)         cause_ExcCode_aux = 5'h8;     // 01000 (EXC_Sys)
        else if (exc_breakpoint)      cause_ExcCode_aux = 5'h9;     // 01001 (EXC_Bp)
        else if (exc_reserved)        cause_ExcCode_aux = 5'ha;     // 01010 (EXC_RI)
        else if (exception_cp)        cause_ExcCode_aux = 5'hb;     // 01011 (EXC_CpU)
        else if (exc_address_if)      cause_ExcCode_aux = 5'h4;     // 00100 (EXC_AdIF)
        else if (exc_ibus_error)      cause_ExcCode_aux = 5'h6;     // 00110 (EXC_IBE)
        else if (exception_interrupt) cause_ExcCode_aux = 5'h0;     // 00000 (EXC_Int)
        else                          cause_ExcCode_aux = 5'bxxxx;  // What the hell?
    end
endmodule // antares_cpzero
