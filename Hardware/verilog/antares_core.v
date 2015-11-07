//==================================================================================================
//  Filename      : antares_core.v
//  Created On    : Sat Sep  5 21:45:33 2015
//  Last Modified : Sat Nov 07 11:56:09 2015
//  Revision      : 1.0
//  Author        : Angel Terrones
//  Company       : Universidad Simón Bolívar
//  Email         : aterrones@usb.ve
//
//  Description   : Antares core.
//==================================================================================================

`include "antares_defines.v"

module antares_core #(parameter ENABLE_HW_MULT = 1,
                      parameter ENABLE_HW_DIV = 1,
                      parameter ENABLE_HW_CLOZ = 1
                      )(
                        input         clk,
                        input         rst,
                        output        halted, // CP0 Status Register, bit 16
                        // Interrupts
                        input [4:0]   interrupts, // External interrupts
                        input         nmi, // Non-maskable interrupt
                        // External Instruction Memory/Instruction Cache
                        input [31:0]  iport_data_i, // Data from memory
                        input         iport_ready, // memory is ready
                        input         iport_error, // Bus error
                        output [31:0] iport_address, // data address
                        output [3:0]  iport_wr, // write = byte select, read = 0000,
                        output        iport_enable, // enable operation
                        // External Data Memory/Data Cache
                        input [31:0]  dport_data_i, // Data from memory
                        input         dport_ready, // memory is ready
                        input         dport_error, // Bus error
                        output [31:0] dport_address, // data address
                        output [31:0] dport_data_o, // data to memory
                        output [3:0]  dport_wr, // write = byte select, read = 0000,
                        output        dport_enable   // enable operation
                        );

    /*AUTOWIRE*/
    // Beginning of automatic wires (for undeclared instantiated-module outputs)
    wire [31:0]         cp0_data_output;        // From cpzero0 of antares_cpzero.v
    wire                dmem_request_stall;     // From load_store_unit0 of antares_load_store_unit.v
    wire [7:0]          dp_hazard;              // From control_unit0 of antares_control_unit.v
    wire [4:0]          ex_alu_operation;       // From IDEX_register of antares_idex_register.v
    wire [1:0]          ex_alu_port_a_select;   // From IDEX_register of antares_idex_register.v
    wire [1:0]          ex_alu_port_b_select;   // From IDEX_register of antares_idex_register.v
    wire [31:0]         ex_data_rs;             // From IDEX_register of antares_idex_register.v
    wire [31:0]         ex_data_rt;             // From IDEX_register of antares_idex_register.v
    wire [3:0]          ex_dp_hazard;           // From IDEX_register of antares_idex_register.v
    wire                ex_flush;               // From cpzero0 of antares_cpzero.v
    wire [1:0]          ex_gpr_wa_select;       // From IDEX_register of antares_idex_register.v
    wire                ex_gpr_we;              // From IDEX_register of antares_idex_register.v
    wire                ex_mem_byte;            // From IDEX_register of antares_idex_register.v
    wire                ex_mem_data_sign_ext;   // From IDEX_register of antares_idex_register.v
    wire                ex_mem_halfword;        // From IDEX_register of antares_idex_register.v
    wire                ex_mem_to_gpr_select;   // From IDEX_register of antares_idex_register.v
    wire                ex_mem_write;           // From IDEX_register of antares_idex_register.v
    wire [4:0]          ex_rs;                  // From IDEX_register of antares_idex_register.v
    wire [4:0]          ex_rt;                  // From IDEX_register of antares_idex_register.v
    wire [16:0]         ex_sign_imm16;          // From IDEX_register of antares_idex_register.v
    wire                ex_stall;               // From hazard_unit0 of antares_hazard_unit.v
    wire                exc_address_if;         // From load_store_unit0 of antares_load_store_unit.v
    wire                exc_address_l_mem;      // From load_store_unit0 of antares_load_store_unit.v
    wire                exc_address_s_mem;      // From load_store_unit0 of antares_load_store_unit.v
    wire                exc_syscall;            // From control_unit0 of antares_control_unit.v
    wire [1:0]          forward_ex_rs;          // From hazard_unit0 of antares_hazard_unit.v
    wire [1:0]          forward_ex_rt;          // From hazard_unit0 of antares_hazard_unit.v
    wire [1:0]          forward_id_rs;          // From hazard_unit0 of antares_hazard_unit.v
    wire [1:0]          forward_id_rt;          // From hazard_unit0 of antares_hazard_unit.v
    wire [4:0]          id_alu_operation;       // From control_unit0 of antares_control_unit.v
    wire [1:0]          id_alu_port_a_select;   // From control_unit0 of antares_control_unit.v
    wire [1:0]          id_alu_port_b_select;   // From control_unit0 of antares_control_unit.v
    wire                id_branch;              // From control_unit0 of antares_control_unit.v
    wire                id_flush;               // From cpzero0 of antares_cpzero.v
    wire [1:0]          id_gpr_wa_select;       // From control_unit0 of antares_control_unit.v
    wire                id_gpr_we;              // From control_unit0 of antares_control_unit.v
    wire [31:0]         id_instruction;         // From IFID_register of antares_ifid_register.v
    wire                id_jump;                // From control_unit0 of antares_control_unit.v
    wire                id_mem_byte;            // From control_unit0 of antares_control_unit.v
    wire                id_mem_data_sign_ext;   // From control_unit0 of antares_control_unit.v
    wire                id_mem_halfword;        // From control_unit0 of antares_control_unit.v
    wire                id_mem_to_gpr_select;   // From control_unit0 of antares_control_unit.v
    wire                id_mem_write;           // From control_unit0 of antares_control_unit.v
    wire [31:0]         id_pc_add4;             // From IFID_register of antares_ifid_register.v
    wire                id_stall;               // From hazard_unit0 of antares_hazard_unit.v
    wire                id_take_branch;         // From branch_unit0 of antares_branch_unit.v
    wire                if_flush;               // From cpzero0 of antares_cpzero.v
    wire [31:0]         if_new_pc;              // From pc_source_exception of antares_mux_2_1.v
    wire [31:0]         if_pc;                  // From pc_register of antares_pc_register.v
    wire [31:0]         if_pc_add4;             // From pc_add4 of antares_add.v
    wire                if_stall;               // From hazard_unit0 of antares_hazard_unit.v
    wire                imem_request_stall;     // From load_store_unit0 of antares_load_store_unit.v
    wire [31:0]         mem_alu_result;         // From EXMEM_register of antares_exmem_register.v
    wire                mem_flush;              // From cpzero0 of antares_cpzero.v
    wire [4:0]          mem_gpr_wa;             // From EXMEM_register of antares_exmem_register.v
    wire                mem_gpr_we;             // From EXMEM_register of antares_exmem_register.v
    wire                mem_mem_byte;           // From EXMEM_register of antares_exmem_register.v
    wire                mem_mem_data_sign_ext;  // From EXMEM_register of antares_exmem_register.v
    wire                mem_mem_halfword;       // From EXMEM_register of antares_exmem_register.v
    wire [31:0]         mem_mem_store_data;     // From EXMEM_register of antares_exmem_register.v
    wire                mem_mem_to_gpr_select;  // From EXMEM_register of antares_exmem_register.v
    wire                mem_mem_write;          // From EXMEM_register of antares_exmem_register.v
    wire                mem_stall;              // From hazard_unit0 of antares_hazard_unit.v
    wire [31:0]         pc_branch_address;      // From branch_unit0 of antares_branch_unit.v
    wire [31:0]         wb_alu_data;            // From MEMWB_register of antares_memwb_register.v
    wire [4:0]          wb_gpr_wa;              // From MEMWB_register of antares_memwb_register.v
    wire                wb_gpr_we;              // From MEMWB_register of antares_memwb_register.v
    wire                wb_mem_to_gpr_select;   // From MEMWB_register of antares_memwb_register.v
    wire [31:0]         wb_read_data;           // From MEMWB_register of antares_memwb_register.v
    wire                wb_stall;               // From hazard_unit0 of antares_hazard_unit.v
    // End of automatics

    // manual wires
    wire [5:0]          opcode;
    wire [4:0]          op_rs;
    wire [4:0]          op_rt;
    wire [4:0]          op_rd;
    wire [5:0]          op_function;
    wire [15:0]         op_imm16;
    wire [25:0]         op_imm26;
    wire [2:0]          op_cp0_select;

    wire    [31:0]  if_instruction;
    wire    [31:0]  id_gpr_rs;
    wire    [31:0]  id_gpr_rt;
    wire    [31:0]  wb_gpr_wd;
    wire    [31:0]  id_forward_rs;
    wire    [31:0]  id_forward_rt;
    wire    [31:0]  ex_forward_rs;
    wire    [31:0]  ex_forward_rt;
    wire    [31:0]  ex_alu_result;
    wire            ex_request_stall;
    wire    [31:0]  ex_alu_port_a;
    wire    [31:0]  ex_alu_port_b;
    wire    [4:0]   ex_gpr_wa;
    wire    [31:0]  mem_read_data;

    wire            halt_0;
    reg             halt_1;
    reg             halt_2;
    reg             halt_3;

    wire            id_mfc0;
    wire            id_mtc0;
    wire            id_eret;
    wire            id_cp1_instruction;
    wire            id_cp2_instruction;
    wire            id_cp3_instruction;
    wire            exc_overflow;
    wire            exc_trap;
    wire            exc_breakpoint;
    wire            exc_reserved;
    wire    [31:0]  id_exception_pc;
    wire    [31:0]  ex_exception_pc;
    wire    [31:0]  mem_exception_pc;
    wire            id_exception_source;
    wire            ex_exception_source;
    wire            mem_exception_source;
    wire            id_is_flushed;
    wire            if_is_bds;
    wire            id_is_bds;
    wire            ex_is_bds;
    wire            mem_is_bds;
    wire            id_kernel_mode;
    wire            ex_kernel_mode;
    wire            mem_kernel_mode;
    wire            if_exception_stall;
    wire            id_exception_stall;
    wire            ex_exception_stall;
    wire            mem_exception_stall;
    wire            exception_pc_select;
    wire    [31:0]  pc_exception;
    wire    [31:0]  pc_pre_exc_selection;
    wire            id_llsc;
    wire            ex_llsc;
    wire            mem_llsc;
    wire            id_movn;
    wire            id_movz;
    wire            ex_movn;
    wire            ex_movz;
    wire            ex_b_is_zero;
    wire            id_trap;
    wire            ex_trap;
    wire            id_trap_condition;
    wire            ex_trap_condition;
    wire            mem_trap;
    wire            mem_trap_condition;
    wire            id_id_exception_source;
    wire            id_ex_exception_source;
    wire            id_mem_exception_source;
    wire            ex_ex_exception_source;
    wire            ex_mem_exception_source;
    wire            mem_mem_exception_source;
    wire            id_imm_sign_ext;
    wire    [31:0]  ex_cp0_data;

    wire            exception_ready;
    wire            pc_source_select;
    wire            if_stall_pc_register;
    wire [7:0]      haz_dp_hazards;

    //--------------------------------------------------------------------------
    // assignments
    //--------------------------------------------------------------------------
    assign opcode                = id_instruction[`ANTARES_INSTR_OPCODE];
    assign op_rs                 = id_instruction[`ANTARES_INSTR_RS];
    assign op_rt                 = id_instruction[`ANTARES_INSTR_RT];
    assign op_rd                 = id_instruction[`ANTARES_INSTR_RD];
    assign op_function           = id_instruction[`ANTARES_INSTR_FUNCT];
    assign op_imm16              = id_instruction[`ANTARES_INSTR_IMM16];
    assign op_imm26              = id_instruction[`ANTARES_INSTR_IMM26];
    assign op_cp0_select         = id_instruction[`ANTARES_INSTR_CP0_SEL];

    assign id_exception_source   = id_id_exception_source | id_ex_exception_source | id_mem_exception_source;
    assign ex_exception_source   = ex_ex_exception_source | ex_mem_exception_source;
    assign mem_exception_source  = mem_mem_exception_source;

    assign if_is_bds             = id_take_branch;
    assign exc_trap              = mem_trap & (mem_trap_condition ^ (mem_alu_result == 32'b0));
    assign pc_source_select      = (id_take_branch & id_branch) | id_jump;
    assign if_stall_pc_register  = if_stall | id_stall | halt_0;

    assign haz_dp_hazards = {dp_hazard[7:4], ex_dp_hazard};

    //------------------------------------------------------------------------------------------------------------------
    // UPDATE: Getting the halt signal from the CP0.
    always @(posedge clk) begin
        if (rst) begin
            halt_1 <= 1'b0;
            halt_2 <= 1'b0;
            halt_3 <= 1'b0;
        end
        else begin
            halt_1 <= halt_0;
            halt_2 <= halt_1;
            halt_3 <= halt_2;
        end
    end // always @ (posedge clk)
    assign halted  = halt_3;

    //--------------------------------------------------------------------------
    // IF stage (A)
    //--------------------------------------------------------------------------
    antares_mux_2_1 pc_source(// Outputs
                              .out    (pc_pre_exc_selection[31:0]),
                              // Inputs
                              .in0    (if_pc_add4[31:0]),
                              .in1    (pc_branch_address[31:0]),
                              .select (pc_source_select)
                              /*AUTOINST*/);

    antares_mux_2_1 pc_source_exception (// Outputs
                                         .out    (if_new_pc[31:0]),
                                         // Inputs
                                         .in0    (pc_pre_exc_selection[31:0]),
                                         .in1    (pc_exception[31:0]),
                                         .select (exception_pc_select)
                                         /*AUTOINST*/);

    antares_pc_register pc_register (// Inputs
                                     .if_stall          (if_stall_pc_register),
                                     /*AUTOINST*/
                                     // Outputs
                                     .if_pc             (if_pc[31:0]),
                                     // Inputs
                                     .clk               (clk),
                                     .rst               (rst),
                                     .if_new_pc         (if_new_pc[31:0]));
    //--------------------------------------------------------------------------
    // IF stage (B)
    //--------------------------------------------------------------------------
    antares_add pc_add4 (// Outputs
                         .c (if_pc_add4[31:0]),
                         // Inputs
                         .a (if_pc[31:0]),
                         .b (32'd4)
                         /*AUTOINST*/);

    antares_ifid_register IFID_register (// Inputs
                                         .if_exception_pc       (if_pc[31:0]),
                                         /*AUTOINST*/
                                         // Outputs
                                         .id_instruction        (id_instruction[31:0]),
                                         .id_pc_add4            (id_pc_add4[31:0]),
                                         .id_exception_pc       (id_exception_pc[31:0]),
                                         .id_is_bds             (id_is_bds),
                                         .id_is_flushed         (id_is_flushed),
                                         // Inputs
                                         .clk                   (clk),
                                         .rst                   (rst),
                                         .if_instruction        (if_instruction[31:0]),
                                         .if_pc_add4            (if_pc_add4[31:0]),
                                         .if_is_bds             (if_is_bds),
                                         .if_flush              (if_flush),
                                         .if_stall              (if_stall),
                                         .id_stall              (id_stall));
    //--------------------------------------------------------------------------
    // ID stage
    //--------------------------------------------------------------------------
    antares_reg_file GPR (// Outputs
                          .gpr_rd_a   (id_gpr_rs[31:0]),
                          .gpr_rd_b   (id_gpr_rt[31:0]),
                          // Inputs
                          .clk        (clk),
                          .gpr_ra_a   (op_rs[4:0]),
                          .gpr_ra_b   (op_rt[4:0]),
                          .gpr_wa     (wb_gpr_wa[4:0]),
                          .gpr_wd     (wb_gpr_wd[31:0]),
                          .gpr_we     (wb_gpr_we)
                          /*AUTOINST*/);

    antares_branch_unit branch_unit0 (// Inputs
                                      .id_data_rs       (id_forward_rs[31:0]),
                                      .id_data_rt       (id_forward_rt[31:0]),
                                      /*AUTOINST*/
                                      // Outputs
                                      .pc_branch_address(pc_branch_address[31:0]),
                                      .id_take_branch   (id_take_branch),
                                      // Inputs
                                      .opcode           (opcode[5:0]),
                                      .id_pc_add4       (id_pc_add4[31:0]),
                                      .op_imm26         (op_imm26[25:0]));

    antares_control_unit #(/*AUTOINSTPARAM*/
                           // Parameters
                           .ENABLE_HW_MULT      (ENABLE_HW_MULT),
                           .ENABLE_HW_DIV       (ENABLE_HW_DIV),
                           .ENABLE_HW_CLOZ      (ENABLE_HW_CLOZ))
                         control_unit0 (// Outputs
                                        .id_syscall              (exc_syscall),
                                        .id_breakpoint           (exc_breakpoint),
                                        .id_reserved             (exc_reserved),
                                        /*AUTOINST*/
                                        // Outputs
                                        .dp_hazard               (dp_hazard[7:0]),
                                        .id_imm_sign_ext         (id_imm_sign_ext),
                                        .id_movn                 (id_movn),
                                        .id_movz                 (id_movz),
                                        .id_llsc                 (id_llsc),
                                        .id_mfc0                 (id_mfc0),
                                        .id_mtc0                 (id_mtc0),
                                        .id_eret                 (id_eret),
                                        .id_cp1_instruction      (id_cp1_instruction),
                                        .id_cp2_instruction      (id_cp2_instruction),
                                        .id_cp3_instruction      (id_cp3_instruction),
                                        .id_id_exception_source  (id_id_exception_source),
                                        .id_ex_exception_source  (id_ex_exception_source),
                                        .id_mem_exception_source (id_mem_exception_source),
                                        .id_trap                 (id_trap),
                                        .id_trap_condition       (id_trap_condition),
                                        .id_gpr_we               (id_gpr_we),
                                        .id_mem_to_gpr_select    (id_mem_to_gpr_select),
                                        .id_alu_operation        (id_alu_operation[4:0]),
                                        .id_alu_port_a_select    (id_alu_port_a_select[1:0]),
                                        .id_alu_port_b_select    (id_alu_port_b_select[1:0]),
                                        .id_gpr_wa_select        (id_gpr_wa_select[1:0]),
                                        .id_jump                 (id_jump),
                                        .id_branch               (id_branch),
                                        .id_mem_write            (id_mem_write),
                                        .id_mem_byte             (id_mem_byte),
                                        .id_mem_halfword         (id_mem_halfword),
                                        .id_mem_data_sign_ext    (id_mem_data_sign_ext),
                                        // Inputs
                                        .opcode                  (opcode[5:0]),
                                        .op_function             (op_function[5:0]),
                                        .op_rs                   (op_rs[4:0]),
                                        .op_rt                   (op_rt[4:0]));

    antares_mux_4_1 ForwardRsID (// Outputs
                                   .out    (id_forward_rs[31:0]),
                                   // Inputs
                                   .in0    (id_gpr_rs[31:0]),
                                   .in1    (mem_alu_result[31:0]),
                                   .in2    (wb_gpr_wd[31:0]),
                                   .in3    (32'bx),
                                   .select (forward_id_rs[1:0])
                                   /*AUTOINST*/);

    antares_mux_4_1 ForwardRtID (// Outputs
                                   .out    (id_forward_rt[31:0]),
                                   // Inputs
                                   .in0    (id_gpr_rt[31:0]),
                                   .in1    (mem_alu_result[31:0]),
                                   .in2    (wb_gpr_wd[31:0]),
                                   .in3    (32'bx),
                                   .select (forward_id_rt[1:0])
                                   /*AUTOINST*/);

    antares_idex_register IDEX_register (// Inputs
                                         .id_data_rs              (id_forward_rs[31:0]),
                                         .id_data_rt              (id_forward_rt[31:0]),
                                         .id_sign_imm16           (op_imm16[15:0]),
                                         .id_cp0_data             (cp0_data_output[31:0]),
                                         .id_rs                   (op_rs[4:0]),
                                         .id_rt                   (op_rt[4:0]),
                                         .id_dp_hazard            (dp_hazard[3:0]),
                                         /*AUTOINST*/
                                         // Outputs
                                         .ex_alu_operation        (ex_alu_operation[4:0]),
                                         .ex_data_rs              (ex_data_rs[31:0]),
                                         .ex_data_rt              (ex_data_rt[31:0]),
                                         .ex_gpr_we               (ex_gpr_we),
                                         .ex_mem_to_gpr_select    (ex_mem_to_gpr_select),
                                         .ex_mem_write            (ex_mem_write),
                                         .ex_alu_port_a_select    (ex_alu_port_a_select[1:0]),
                                         .ex_alu_port_b_select    (ex_alu_port_b_select[1:0]),
                                         .ex_gpr_wa_select        (ex_gpr_wa_select[1:0]),
                                         .ex_mem_byte             (ex_mem_byte),
                                         .ex_mem_halfword         (ex_mem_halfword),
                                         .ex_mem_data_sign_ext    (ex_mem_data_sign_ext),
                                         .ex_rs                   (ex_rs[4:0]),
                                         .ex_rt                   (ex_rt[4:0]),
                                         .ex_dp_hazard            (ex_dp_hazard[3:0]),
                                         .ex_sign_imm16           (ex_sign_imm16[16:0]),
                                         .ex_cp0_data             (ex_cp0_data[31:0]),
                                         .ex_exception_pc         (ex_exception_pc[31:0]),
                                         .ex_movn                 (ex_movn),
                                         .ex_movz                 (ex_movz),
                                         .ex_llsc                 (ex_llsc),
                                         .ex_kernel_mode          (ex_kernel_mode),
                                         .ex_is_bds               (ex_is_bds),
                                         .ex_trap                 (ex_trap),
                                         .ex_trap_condition       (ex_trap_condition),
                                         .ex_ex_exception_source  (ex_ex_exception_source),
                                         .ex_mem_exception_source (ex_mem_exception_source),
                                         // Inputs
                                         .clk                     (clk),
                                         .rst                     (rst),
                                         .id_alu_operation        (id_alu_operation[4:0]),
                                         .id_gpr_we               (id_gpr_we),
                                         .id_mem_to_gpr_select    (id_mem_to_gpr_select),
                                         .id_mem_write            (id_mem_write),
                                         .id_alu_port_a_select    (id_alu_port_a_select[1:0]),
                                         .id_alu_port_b_select    (id_alu_port_b_select[1:0]),
                                         .id_gpr_wa_select        (id_gpr_wa_select[1:0]),
                                         .id_mem_byte             (id_mem_byte),
                                         .id_mem_halfword         (id_mem_halfword),
                                         .id_mem_data_sign_ext    (id_mem_data_sign_ext),
                                         .id_imm_sign_ext         (id_imm_sign_ext),
                                         .id_exception_pc         (id_exception_pc[31:0]),
                                         .id_movn                 (id_movn),
                                         .id_movz                 (id_movz),
                                         .id_llsc                 (id_llsc),
                                         .id_kernel_mode          (id_kernel_mode),
                                         .id_is_bds               (id_is_bds),
                                         .id_trap                 (id_trap),
                                         .id_trap_condition       (id_trap_condition),
                                         .id_ex_exception_source  (id_ex_exception_source),
                                         .id_mem_exception_source (id_mem_exception_source),
                                         .id_flush                (id_flush),
                                         .id_stall                (id_stall),
                                         .ex_stall                (ex_stall));
    //--------------------------------------------------------------------------
    // EX stage
    //--------------------------------------------------------------------------
    antares_alu #(/*AUTOINSTPARAM*/
                  // Parameters
                  .ENABLE_HW_MULT       (ENABLE_HW_MULT),
                  .ENABLE_HW_DIV        (ENABLE_HW_DIV),
                  .ENABLE_HW_CLOZ       (ENABLE_HW_CLOZ))
                execution_unit (/*AUTOINST*/
                                // Outputs
                                .ex_request_stall (ex_request_stall),
                                .ex_alu_result    (ex_alu_result[31:0]),
                                .ex_b_is_zero     (ex_b_is_zero),
                                .exc_overflow     (exc_overflow),
                                // Inputs
                                .clk              (clk),
                                .rst              (rst),
                                .ex_alu_port_a    (ex_alu_port_a[31:0]),
                                .ex_alu_port_b    (ex_alu_port_b[31:0]),
                                .ex_alu_operation (ex_alu_operation[4:0]),
                                .ex_stall         (ex_stall),
                                .ex_flush         (ex_flush));

    antares_mux_4_1 forward_rs_ex (// Outputs
                                   .out    (ex_forward_rs[31:0]),
                                   // Inputs
                                   .in0    (ex_data_rs[31:0]),
                                   .in1    (mem_alu_result[31:0]),
                                   .in2    (wb_gpr_wd[31:0]),
                                   .in3    (32'bx),
                                   .select (forward_ex_rs[1:0])
                                   /*AUTOINST*/);

    antares_mux_4_1 forward_rt_ex (// Outputs
                                   .out    (ex_forward_rt[31:0]),
                                   // Inputs
                                   .in0    (ex_data_rt[31:0]),
                                   .in1    (mem_alu_result[31:0]),
                                   .in2    (wb_gpr_wd[31:0]),
                                   .in3    (32'bx),
                                   .select (forward_ex_rt[1:0])
                                   /*AUTOINST*/);

    antares_mux_4_1 ALUPortA (// Outputs
                              .out    (ex_alu_port_a[31:0]),
                              // Inputs
                              .in0    (ex_forward_rs[31:0]),
                              .in1    ({27'b0, ex_sign_imm16[10:6]}), // shamnt
                              .in2    (32'd8), // PC + 8
                              .in3    (32'd16),
                              .select (ex_alu_port_a_select[1:0])
                              /*AUTOINST*/);

    antares_mux_4_1 ALUPortB (// Outputs
                              .out    (ex_alu_port_b[31:0]),
                              // Inputs
                              .in0    (ex_forward_rt[31:0]),
                              .in1    ({{15{ex_sign_imm16[16]}}, ex_sign_imm16[16:0]}),
                              .in2    (ex_exception_pc[31:0]),
                              .in3    (ex_cp0_data[31:0]),
                              .select (ex_alu_port_b_select[1:0])
                              /*AUTOINST*/);

    antares_mux_4_1 #(.WIDTH(5))
        mux_reg_wa(// Outputs
                   .out    (ex_gpr_wa[4:0]),
                   // Inputs
                   .in0    (ex_sign_imm16[15:11]), // Rd
                   .in1    (ex_rt[4:0]),
                   .in2    (5'b11111), // $31 = $Ra
                   .in3    (5'b00000), // NOP
                   .select (ex_gpr_wa_select[1:0])
                   /*AUTOINST*/);

    antares_exmem_register EXMEM_register (// Inputs
                                           .ex_mem_store_data        (ex_forward_rt[31:0]),
                                           /*AUTOINST*/
                                           // Outputs
                                           .mem_alu_result           (mem_alu_result[31:0]),
                                           .mem_mem_store_data       (mem_mem_store_data[31:0]),
                                           .mem_gpr_wa               (mem_gpr_wa[4:0]),
                                           .mem_gpr_we               (mem_gpr_we),
                                           .mem_mem_to_gpr_select    (mem_mem_to_gpr_select),
                                           .mem_mem_write            (mem_mem_write),
                                           .mem_mem_byte             (mem_mem_byte),
                                           .mem_mem_halfword         (mem_mem_halfword),
                                           .mem_mem_data_sign_ext    (mem_mem_data_sign_ext),
                                           .mem_exception_pc         (mem_exception_pc[31:0]),
                                           .mem_llsc                 (mem_llsc),
                                           .mem_kernel_mode          (mem_kernel_mode),
                                           .mem_is_bds               (mem_is_bds),
                                           .mem_trap                 (mem_trap),
                                           .mem_trap_condition       (mem_trap_condition),
                                           .mem_mem_exception_source (mem_mem_exception_source),
                                           // Inputs
                                           .clk                      (clk),
                                           .rst                      (rst),
                                           .ex_alu_result            (ex_alu_result[31:0]),
                                           .ex_gpr_wa                (ex_gpr_wa[4:0]),
                                           .ex_gpr_we                (ex_gpr_we),
                                           .ex_mem_to_gpr_select     (ex_mem_to_gpr_select),
                                           .ex_mem_write             (ex_mem_write),
                                           .ex_mem_byte              (ex_mem_byte),
                                           .ex_mem_halfword          (ex_mem_halfword),
                                           .ex_mem_data_sign_ext     (ex_mem_data_sign_ext),
                                           .ex_exception_pc          (ex_exception_pc[31:0]),
                                           .ex_movn                  (ex_movn),
                                           .ex_movz                  (ex_movz),
                                           .ex_b_is_zero             (ex_b_is_zero),
                                           .ex_llsc                  (ex_llsc),
                                           .ex_kernel_mode           (ex_kernel_mode),
                                           .ex_is_bds                (ex_is_bds),
                                           .ex_trap                  (ex_trap),
                                           .ex_trap_condition        (ex_trap_condition),
                                           .ex_mem_exception_source  (ex_mem_exception_source),
                                           .ex_flush                 (ex_flush),
                                           .ex_stall                 (ex_stall),
                                           .mem_stall                (mem_stall));
    //--------------------------------------------------------------------------
    // MEM stage
    //--------------------------------------------------------------------------
    antares_memwb_register MEMWB_register (// Inputs
                                           .mem_alu_data          (mem_alu_result[31:0]),
                                           /*AUTOINST*/
                                           // Outputs
                                           .wb_read_data          (wb_read_data[31:0]),
                                           .wb_alu_data           (wb_alu_data[31:0]),
                                           .wb_gpr_wa             (wb_gpr_wa[4:0]),
                                           .wb_mem_to_gpr_select  (wb_mem_to_gpr_select),
                                           .wb_gpr_we             (wb_gpr_we),
                                           // Inputs
                                           .clk                   (clk),
                                           .rst                   (rst),
                                           .mem_read_data         (mem_read_data[31:0]),
                                           .mem_gpr_wa            (mem_gpr_wa[4:0]),
                                           .mem_mem_to_gpr_select (mem_mem_to_gpr_select),
                                           .mem_gpr_we            (mem_gpr_we),
                                           .mem_flush             (mem_flush),
                                           .mem_stall             (mem_stall),
                                           .wb_stall              (wb_stall));
    //--------------------------------------------------------------------------
    // WB stage
    //--------------------------------------------------------------------------
    antares_mux_2_1 mux_mem_ex_result (// Outputs
                                       .out    (wb_gpr_wd[31:0]),
                                       // Inputs
                                       .in0    (wb_alu_data[31:0]),
                                       .in1    (wb_read_data[31:0]),
                                       .select (wb_mem_to_gpr_select)
                                       /*AUTOINST*/);
    //--------------------------------------------------------------------------
    // HDU, LSU and CP0
    //--------------------------------------------------------------------------
    antares_hazard_unit hazard_unit0 (// Inputs
                                      .id_rs               (op_rs[4:0]),
                                      .id_rt               (op_rt[4:0]),
                                      .mem_mem_read        (mem_mem_to_gpr_select),
                                      .DP_Hazards          (haz_dp_hazards[7:0]),
                                      /*AUTOINST*/
                                      // Outputs
                                      .forward_id_rs       (forward_id_rs[1:0]),
                                      .forward_id_rt       (forward_id_rt[1:0]),
                                      .forward_ex_rs       (forward_ex_rs[1:0]),
                                      .forward_ex_rt       (forward_ex_rt[1:0]),
                                      .if_stall            (if_stall),
                                      .id_stall            (id_stall),
                                      .ex_stall            (ex_stall),
                                      .mem_stall           (mem_stall),
                                      .wb_stall            (wb_stall),
                                      // Inputs
                                      .ex_rs               (ex_rs[4:0]),
                                      .ex_rt               (ex_rt[4:0]),
                                      .ex_gpr_wa           (ex_gpr_wa[4:0]),
                                      .mem_gpr_wa          (mem_gpr_wa[4:0]),
                                      .wb_gpr_wa           (wb_gpr_wa[4:0]),
                                      .ex_gpr_we           (ex_gpr_we),
                                      .mem_gpr_we          (mem_gpr_we),
                                      .wb_gpr_we           (wb_gpr_we),
                                      .mem_mem_write       (mem_mem_write),
                                      .ex_request_stall    (ex_request_stall),
                                      .dmem_request_stall  (dmem_request_stall),
                                      .imem_request_stall  (imem_request_stall),
                                      .if_exception_stall  (if_exception_stall),
                                      .id_exception_stall  (id_exception_stall),
                                      .ex_exception_stall  (ex_exception_stall),
                                      .mem_exception_stall (mem_exception_stall));

    antares_load_store_unit load_store_unit0 (// Outputs
                                              .imem_data          (if_instruction[31:0]),
                                              .dmem_data_o        (mem_read_data[31:0]),
                                              // Inputs
                                              .imem_address       (if_pc[31:0]),
                                              .dmem_address       (mem_alu_result[31:0]),
                                              .dmem_data_i        (mem_mem_store_data[31:0]),
                                              .dmem_halfword      (mem_mem_halfword),
                                              .dmem_byte          (mem_mem_byte),
                                              .dmem_read          (mem_mem_to_gpr_select),
                                              .dmem_write         (mem_mem_write),
                                              .dmem_sign_extend   (mem_mem_data_sign_ext),
                                              /*AUTOINST*/
                                              // Outputs
                                              .iport_address      (iport_address[31:0]),
                                              .iport_wr           (iport_wr[3:0]),
                                              .iport_enable       (iport_enable),
                                              .dport_address      (dport_address[31:0]),
                                              .dport_data_o       (dport_data_o[31:0]),
                                              .dport_wr           (dport_wr[3:0]),
                                              .dport_enable       (dport_enable),
                                              .exc_address_if     (exc_address_if),
                                              .exc_address_l_mem  (exc_address_l_mem),
                                              .exc_address_s_mem  (exc_address_s_mem),
                                              .imem_request_stall (imem_request_stall),
                                              .dmem_request_stall (dmem_request_stall),
                                              // Inputs
                                              .clk                (clk),
                                              .rst                (rst),
                                              .iport_data_i       (iport_data_i[31:0]),
                                              .iport_ready        (iport_ready),
                                              .iport_error        (iport_error),
                                              .dport_data_i       (dport_data_i[31:0]),
                                              .dport_ready        (dport_ready),
                                              .dport_error        (dport_error),
                                              .exception_ready    (exception_ready),
                                              .mem_kernel_mode    (mem_kernel_mode),
                                              .mem_llsc           (mem_llsc),
                                              .id_eret            (id_eret));

    antares_cpzero cpzero0 (// Outputs
                            .halt                 (halt_0),
                            // Inputs
                            .mfc0                 (id_mfc0),
                            .mtc0                 (id_mtc0),
                            .eret                 (id_eret),
                            .cp1_instruction      (id_cp1_instruction),
                            .cp2_instruction      (id_cp2_instruction),
                            .cp3_instruction      (id_cp3_instruction),
                            .register_address     (op_rd[4:0]),
                            .select               (op_cp0_select[2:0]),
                            .data_input           (id_forward_rt[31:0]),
                            .exc_nmi              (nmi),
                            .exc_ibus_error       (iport_error),
                            .exc_dbus_error       (dport_error),
                            .bad_address_if       (if_pc[31:0]),
                            .bad_address_mem      (mem_alu_result[31:0]),
                            /*AUTOINST*/
                            // Outputs
                            .cp0_data_output      (cp0_data_output[31:0]),
                            .id_kernel_mode       (id_kernel_mode),
                            .if_exception_stall   (if_exception_stall),
                            .id_exception_stall   (id_exception_stall),
                            .ex_exception_stall   (ex_exception_stall),
                            .mem_exception_stall  (mem_exception_stall),
                            .if_flush             (if_flush),
                            .id_flush             (id_flush),
                            .ex_flush             (ex_flush),
                            .mem_flush            (mem_flush),
                            .exception_ready      (exception_ready),
                            .exception_pc_select  (exception_pc_select),
                            .pc_exception         (pc_exception[31:0]),
                            // Inputs
                            .clk                  (clk),
                            .if_stall             (if_stall),
                            .id_stall             (id_stall),
                            .interrupts           (interrupts[4:0]),
                            .rst                  (rst),
                            .exc_address_if       (exc_address_if),
                            .exc_address_l_mem    (exc_address_l_mem),
                            .exc_address_s_mem    (exc_address_s_mem),
                            .exc_overflow         (exc_overflow),
                            .exc_trap             (exc_trap),
                            .exc_syscall          (exc_syscall),
                            .exc_breakpoint       (exc_breakpoint),
                            .exc_reserved         (exc_reserved),
                            .id_exception_pc      (id_exception_pc[31:0]),
                            .ex_exception_pc      (ex_exception_pc[31:0]),
                            .mem_exception_pc     (mem_exception_pc[31:0]),
                            .id_exception_source  (id_exception_source),
                            .ex_exception_source  (ex_exception_source),
                            .mem_exception_source (mem_exception_source),
                            .id_is_flushed        (id_is_flushed),
                            .if_is_bds            (if_is_bds),
                            .id_is_bds            (id_is_bds),
                            .ex_is_bds            (ex_is_bds),
                            .mem_is_bds           (mem_is_bds));
endmodule // antares_core
