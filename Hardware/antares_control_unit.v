//==================================================================================================
//  Filename      : antares_control_unit.v
//  Created On    : Fri Sep  4 11:55:21 2015
//  Last Modified : Fri Sep 04 15:35:04 2015
//  Revision      : 1.0
//  Author        : Angel Terrones
//  Company       : Universidad Simón Bolívar
//  Email         : aterrones@usb.ve
//
//  Description   : Instruction decode and control unit (no pipeline control)
//==================================================================================================

`include "antares_defines.v"

module antares_control_unit #(parameter ENABLE_HW_MULT = 1, // Enable multiply instructions
                              parameter ENABLE_HW_DIV = 1, // Enable div instructions
                              parameter ENABLE_HW_CLOZ = 1) // Enable CL=/CLZ instructions
    (/*AUTOARG*/
    // Outputs
    id_imm_sign_ext, id_movn, id_movz, id_llsc, id_syscall, id_breakpoint,
    id_reserved, id_mfc0, id_mtc0, id_eret, id_cp1_instruction,
    id_cp2_instruction, id_cp3_instruction, id_id_exception_source,
    id_ex_exception_source, id_mem_exception_source, id_trap, id_trap_condition,
    id_gpr_we, id_mem_to_gpr_select, id_alu_operation, id_alu_port_a_select,
    id_alu_port_b_select, id_gpr_wa_select, id_jump, id_branch, id_mem_write,
    id_mem_byte, id_mem_halfword, id_mem_data_sign_ext,
    // Inputs
    opcode, op_function, op_rs, op_rt
    );

    input [5:0]  opcode;                  // The instruction opcode
    input [5:0]  op_function;             // For RR-type instruction
    input [4:0]  op_rs;                   // For mtc0 and mfc0 instructions
    input [4:0]  op_rt;                   // For branch instructions
    output       id_imm_sign_ext;         // sign extend the imm16
    output       id_movn;                 // MOVN instruction
    output       id_movz;                 // MOVZ instruction
    output       id_llsc;                 // LL/SC instructions
    output       id_syscall;              // Syscall exception
    output       id_breakpoint;           // Breakpoint exception
    output       id_reserved;             // Reserved instruction exception
    output       id_mfc0;                 // Coprocessor 0 instruction
    output       id_mtc0;                 // Coprocessor 0 instruction
    output       id_eret;                 // Coprocessor 0 instruction
    output       id_cp1_instruction;      // Coprocessor 1 instruction
    output       id_cp2_instruction;      // Coprocessor 2 instruction
    output       id_cp3_instruction;      // Coprocessor 3 instruction
    output       id_id_exception_source;  // Instruction is a potential source of exception
    output       id_ex_exception_source;  // Instruction is a potential source of exception
    output       id_mem_exception_source; // Instruction is a potential source of exception
    output       id_trap;                 // Trap instruction
    output       id_trap_condition;       // Trap condition
    output       id_gpr_we;               // write data from WB stage, to GPR
    output       id_mem_to_gpr_select;    // Select GPR write data: MEM or ALU
    output [4:0] id_alu_operation;        // ALU function
    output [1:0] id_alu_port_a_select;    // Shift, jump and link
    output [1:0] id_alu_port_b_select;    // R-instruction, I-instruction or jump
    output [1:0] id_gpr_wa_select;        // Select GPR write address
    output       id_jump;                 // Jump instruction
    output       id_branch;               // Branch instruction
    output       id_mem_write;            // Write to Memory: 0 = read, 1 = write.
    output       id_mem_byte;             // Read/Write one byte
    output       id_mem_halfword;         // Read/Write halfword (16 bits)
    output       id_mem_data_sign_ext;    // Sign extend for byte/halfword memory operations

    //--------------------------------------------------------------------------
    // Signal Declaration: reg
    //--------------------------------------------------------------------------
    reg     [20:0]  datapath;               // all control signals
    reg     [2:0]   exception_source;       // exception source signals

    //--------------------------------------------------------------------------
    // Signal Declaration: wires
    //--------------------------------------------------------------------------
    wire    no_mult;
    wire    no_div;
    wire    no_clo_clz;

    //--------------------------------------------------------------------------
    // assigments
    //--------------------------------------------------------------------------
    assign id_imm_sign_ext     = (opcode != `OP_ANDI) & (opcode != `OP_ORI) & (opcode != `OP_XORI);    // The only ones to use the zero ext
    assign id_movn             = (opcode == `OP_TYPE_R) & (op_function == `FUNCTION_OP_MOVN);
    assign id_movz             = (opcode == `OP_TYPE_R) & (op_function == `FUNCTION_OP_MOVZ);
    assign id_llsc             = (opcode == `OP_LL) | (opcode == `OP_SC);
    assign id_syscall          = (opcode == `OP_TYPE_R) & (op_function == `FUNCTION_OP_SYSCALL);
    assign id_breakpoint       = (opcode == `OP_TYPE_R) & (op_function == `FUNCTION_OP_BREAK);
    assign id_mfc0             = (opcode == `OP_TYPE_CP0) & (op_rs == `RS_OP_MFC);
    assign id_mtc0             = (opcode == `OP_TYPE_CP0) & (op_rs == `RS_OP_MTC);
    assign id_eret             = (opcode == `OP_TYPE_CP0) & (op_rs == `RS_OP_ERET) & (op_function == `FUNCTION_OP_ERET);
    assign id_cp1_instruction  = (opcode == `OP_TYPE_CP1);
    assign id_cp2_instruction  = (opcode == `OP_TYPE_CP2);
    assign id_cp3_instruction  = (opcode == `OP_TYPE_CP3);
    assign id_reserved         = no_mult | no_div | no_clo_clz;

    //--------------------------------------------------------------------------
    // Check for mult instructions
    //--------------------------------------------------------------------------
    generate
        if(ENABLE_HW_MULT) begin
            assign no_mult = 1'b0;
        end
        else begin
            assign no_mult = ((datapath[20:16] == `ALU_OP_MADD) | (datapath[20:16] == `ALU_OP_MADDU) |
                              (datapath[20:16] == `ALU_OP_MSUB) | (datapath[20:16] == `ALU_OP_MSUBU) |
                              (datapath[20:16] == `ALU_OP_MULS) | (datapath[20:16] == `ALU_OP_MULU));
        end
    endgenerate

    //--------------------------------------------------------------------------
    // Check for div instructions
    //--------------------------------------------------------------------------
    generate
        if(ENABLE_HW_DIV) begin
            assign no_div = 1'b0;
        end
        else begin
            assign no_div = ((datapath[20:16] == `ALU_OP_DIV) | (datapath[20:16] == `ALU_OP_DIVU));
        end
    endgenerate

    //--------------------------------------------------------------------------
    // Check for CL0/CLZ instructions
    //--------------------------------------------------------------------------
    generate
        if(ENABLE_HW_CLOZ) begin
            assign no_clo_clz = 1'b0;
        end
        else begin
            assign no_clo_clz = ((datapath[20:16] == `ALU_OP_CLO) | (datapath[20:16] == `ALU_OP_CLZ));
        end
    endgenerate

    /*
        Exception.

        All signals are active High.

        ----------------------------------------------------------------------------
            Bit     Meaning
        ----------------------------------------------------------------------------
            2  :    Instruction can cause exception @ ID
            1  :    Instruction can cause exception @ EX
            0  :    Instruction can cause exception @ MEM
        ----------------------------------------------------------------------------
    */
    assign id_id_exception_source  = exception_source[2];
    assign id_ex_exception_source  = exception_source[1];
    assign id_mem_exception_source = exception_source[0];

    /*
        Datapath controls.
    All signals are active High.
    ----------------------------------------------------------------------------
        Bit     Name                Description
    ----------------------------------------------------------------------------
        20 :    id_alu_operation        Operation to execute.
        19 :    .
        18 :    .
        17 :    .
        16 :    .
        -------------------------------
        15:     id_trap                 Trap instruction
        14:     id_trap_condition       Condition: ALU result = 0 (0), ALU result != 0 (1)
        -------------------------------
        13 :    id_gpr_we               Write enable (GPR)
        12 :    id_mem_to_gpr_select    Select data: ALU(0), MEM(1)
        -------------------------------
        11 :    id_alu_port_a_select    Select: Rs(0), shamt(1), 0x04(2), 0x10(3)
        10 :    .
        9  :    id_alu_port_b_select    Select: Rt(0), SImm16(1), PCAdd4(2), ZImm16(3)
        8  :    .
        7  :    id_gpr_wa_select        Select register: Rd(0), Rt(1), 31(2)
        6  :    .
        -------------------------------
        5  :    id_jump                 Jump instruction
        4  :    id_branch               Branch instruction
        -------------------------------
        3  :    id_mem_write            Write to data memory
        2  :    id_mem_byte             Enable read/write one byte
        1  :    id_mem_halfword         Enable read/write 2 bytes (16 bits data)
        0  :    id_mem_data_sign_ext    Zero extend data (0) or Sign extend data (1)
    ----------------------------------------------------------------------------
    */
    assign id_alu_operation     = datapath[20:16];
    assign id_trap              = datapath[15];
    assign id_trap_condition    = datapath[14];
    assign id_gpr_we            = datapath[13];
    assign id_mem_to_gpr_select = datapath[12];
    assign id_alu_port_a_select = datapath[11:10];
    assign id_alu_port_b_select = datapath[9:8];
    assign id_gpr_wa_select     = datapath[7:6];
    assign id_jump              = datapath[5];
    assign id_branch            = datapath[4];
    assign id_mem_write         = datapath[3];
    assign id_mem_byte          = datapath[2];
    assign id_mem_halfword      = datapath[1];
    assign id_mem_data_sign_ext = datapath[0];

    //--------------------------------------------------------------------------
    // set the control signals
    //--------------------------------------------------------------------------
    always @(*) begin
        case(opcode)
            `OP_TYPE_R      :   begin
                                    case (op_function)
                                        `FUNCTION_OP_ADD     : begin datapath = `DP_ADD;     exception_source = `EXC_ADD;     end
                                        `FUNCTION_OP_ADDU    : begin datapath = `DP_ADDU;    exception_source = `EXC_ADDU;    end
                                        `FUNCTION_OP_AND     : begin datapath = `DP_AND;     exception_source = `EXC_AND;     end
                                        `FUNCTION_OP_BREAK   : begin datapath = `DP_BREAK;   exception_source = `EXC_BREAK;   end
                                        `FUNCTION_OP_DIV     : begin datapath = `DP_DIV;     exception_source = `EXC_DIV;     end
                                        `FUNCTION_OP_DIVU    : begin datapath = `DP_DIVU;    exception_source = `EXC_DIVU;    end
                                        `FUNCTION_OP_JALR    : begin datapath = `DP_JALR;    exception_source = `EXC_JALR;    end
                                        `FUNCTION_OP_JR      : begin datapath = `DP_JR;      exception_source = `EXC_JR;      end
                                        `FUNCTION_OP_MFHI    : begin datapath = `DP_MFHI;    exception_source = `EXC_MFHI;    end
                                        `FUNCTION_OP_MFLO    : begin datapath = `DP_MFLO;    exception_source = `EXC_MFLO;    end
                                        `FUNCTION_OP_MOVN    : begin datapath = `DP_MOVN;    exception_source = `EXC_MOVN;    end
                                        `FUNCTION_OP_MOVZ    : begin datapath = `DP_MOVZ;    exception_source = `EXC_MOVZ;    end
                                        `FUNCTION_OP_MTHI    : begin datapath = `DP_MTHI;    exception_source = `EXC_MTHI;    end
                                        `FUNCTION_OP_MTLO    : begin datapath = `DP_MTLO;    exception_source = `EXC_MTLO;    end
                                        `FUNCTION_OP_MULT    : begin datapath = `DP_MULT;    exception_source = `EXC_MULT;    end
                                        `FUNCTION_OP_MULTU   : begin datapath = `DP_MULTU;   exception_source = `EXC_MULTU;   end
                                        `FUNCTION_OP_NOR     : begin datapath = `DP_NOR;     exception_source = `EXC_NOR;     end
                                        `FUNCTION_OP_OR      : begin datapath = `DP_OR;      exception_source = `EXC_OR;      end
                                        `FUNCTION_OP_SLL     : begin datapath = `DP_SLL;     exception_source = `EXC_SLL;     end
                                        `FUNCTION_OP_SLLV    : begin datapath = `DP_SLLV;    exception_source = `EXC_SLLV;    end
                                        `FUNCTION_OP_SLT     : begin datapath = `DP_SLT;     exception_source = `EXC_SLT;     end
                                        `FUNCTION_OP_SLTU    : begin datapath = `DP_SLTU;    exception_source = `EXC_SLTU;    end
                                        `FUNCTION_OP_SRA     : begin datapath = `DP_SRA;     exception_source = `EXC_SRA;     end
                                        `FUNCTION_OP_SRAV    : begin datapath = `DP_SRAV;    exception_source = `EXC_SRAV;    end
                                        `FUNCTION_OP_SRL     : begin datapath = `DP_SRL;     exception_source = `EXC_SRL;     end
                                        `FUNCTION_OP_SRLV    : begin datapath = `DP_SRLV;    exception_source = `EXC_SRLV;    end
                                        `FUNCTION_OP_SUB     : begin datapath = `DP_SUB;     exception_source = `EXC_SUB;     end
                                        `FUNCTION_OP_SUBU    : begin datapath = `DP_SUBU;    exception_source = `EXC_SUBU;    end
                                        `FUNCTION_OP_SYSCALL : begin datapath = `DP_SYSCALL; exception_source = `EXC_SYSCALL; end
                                        `FUNCTION_OP_TEQ     : begin datapath = `DP_TEQ;     exception_source = `EXC_TEQ;     end
                                        `FUNCTION_OP_TGE     : begin datapath = `DP_TGE;     exception_source = `EXC_TGE;     end
                                        `FUNCTION_OP_TGEU    : begin datapath = `DP_TGEU;    exception_source = `EXC_TGEU;    end
                                        `FUNCTION_OP_TLT     : begin datapath = `DP_TLT;     exception_source = `EXC_TLT;     end
                                        `FUNCTION_OP_TLTU    : begin datapath = `DP_TLTU;    exception_source = `EXC_TLTU;    end
                                        `FUNCTION_OP_TNE     : begin datapath = `DP_TNE;     exception_source = `EXC_TNE;     end
                                        `FUNCTION_OP_XOR     : begin datapath = `DP_XOR;     exception_source = `EXC_XOR;     end
                                        default              : begin datapath = `DP_NONE;    exception_source = `EXC_ADDU;    end
                                    endcase // case (op_function)
            end // case: `OP_TYPE_R
            `OP_TYPE_R2     :   begin
                                    case (op_function)
                                        `FUNCTION_OP_CLO   : begin datapath = `DP_CLO;   exception_source = `EXC_CLO;   end
                                        `FUNCTION_OP_CLZ   : begin datapath = `DP_CLZ;   exception_source = `EXC_CLZ;   end
                                        `FUNCTION_OP_MADD  : begin datapath = `DP_MADD;  exception_source = `EXC_MADD;  end
                                        `FUNCTION_OP_MADDU : begin datapath = `DP_MADDU; exception_source = `EXC_MADDU; end
                                        `FUNCTION_OP_MSUB  : begin datapath = `DP_MSUB;  exception_source = `EXC_MSUB;  end
                                        `FUNCTION_OP_MSUBU : begin datapath = `DP_MSUBU; exception_source = `EXC_MSUBU; end
                                        default            : begin datapath = `DP_NONE;  exception_source = `EXC_ADDU;  end
                                    endcase // case (op_function)
            end // case: `OP_TYPE_R2
            `OP_TYPE_REGIMM :   begin
                                    case (op_rt)
                                        `RT_OP_BGEZ   : begin datapath = `DP_BGEZ;   exception_source = `EXC_BGEZ;   end
                                        `RT_OP_BGEZAL : begin datapath = `DP_BGEZAL; exception_source = `EXC_BGEZAL; end
                                        `RT_OP_BLTZ   : begin datapath = `DP_BLTZ;   exception_source = `EXC_BLTZ;   end
                                        `RT_OP_BLTZAL : begin datapath = `DP_BLTZAL; exception_source = `EXC_BLTZAL; end
                                        `RT_OP_TEQI   : begin datapath = `DP_TEQI;   exception_source = `EXC_TEQI;   end
                                        `RT_OP_TGEI   : begin datapath = `DP_TGEI;   exception_source = `EXC_TGEI;   end
                                        `RT_OP_TGEIU  : begin datapath = `DP_TGEIU;  exception_source = `EXC_TGEIU;  end
                                        `RT_OP_TLTI   : begin datapath = `DP_TLTI;   exception_source = `EXC_TLTI;   end
                                        `RT_OP_TLTIU  : begin datapath = `DP_TLTIU;  exception_source = `EXC_TLTIU;  end
                                        `RT_OP_TNEI   : begin datapath = `DP_TNEI;   exception_source = `EXC_TNEI;   end
                                        default       : begin datapath = `DP_NONE;   exception_source = `EXC_ADDU;   end
                                    endcase // case (op_rt)
            end // case: `OP_TYPE_REGIMM
            `OP_TYPE_CP0    :   begin
                                    case (op_rs)
                                        `RS_OP_MFC  : begin datapath = `DP_MFC0; exception_source = `EXC_MFC0; end
                                        `RS_OP_MTC  : begin datapath = `DP_MTC0; exception_source = `EXC_MTC0; end
                                        `RS_OP_ERET : begin datapath = `DP_ERET; exception_source = `EXC_ERET; end
                                        default     : begin datapath = `DP_NONE; exception_source = `EXC_ADDU; end
                                    endcase // case (op_rs)
            end
            `OP_ADDI        :   begin datapath = `DP_ADDI;  exception_source = `EXC_ADDI;  end
            `OP_ADDIU       :   begin datapath = `DP_ADDIU; exception_source = `EXC_ADDIU; end
            `OP_ANDI        :   begin datapath = `DP_ANDI;  exception_source = `EXC_ANDI;  end
            `OP_BEQ         :   begin datapath = `DP_BEQ;   exception_source = `EXC_BEQ;   end
            `OP_BGTZ        :   begin datapath = `DP_BGTZ;  exception_source = `EXC_BGTZ;  end
            `OP_BLEZ        :   begin datapath = `DP_BLEZ;  exception_source = `EXC_BLEZ;  end
            `OP_BNE         :   begin datapath = `DP_BNE;   exception_source = `EXC_BNE;   end
            `OP_J           :   begin datapath = `DP_J;     exception_source = `EXC_J;     end
            `OP_JAL         :   begin datapath = `DP_JAL;   exception_source = `EXC_JAL;   end
            `OP_LB          :   begin datapath = `DP_LB;    exception_source = `EXC_LB;    end
            `OP_LBU         :   begin datapath = `DP_LBU;   exception_source = `EXC_LBU;   end
            `OP_LH          :   begin datapath = `DP_LH;    exception_source = `EXC_LH;    end
            `OP_LHU         :   begin datapath = `DP_LHU;   exception_source = `EXC_LHU;   end
            `OP_LL          :   begin datapath = `DP_LL;    exception_source = `EXC_LL;    end
            `OP_LUI         :   begin datapath = `DP_LUI;   exception_source = `EXC_LUI;   end
            `OP_LW          :   begin datapath = `DP_LW;    exception_source = `EXC_LW;    end
            `OP_ORI         :   begin datapath = `DP_ORI;   exception_source = `EXC_ORI;   end
            `OP_SB          :   begin datapath = `DP_SB;    exception_source = `EXC_SB;    end
            `OP_SC          :   begin datapath = `DP_SC;    exception_source = `EXC_SC;    end
            `OP_SH          :   begin datapath = `DP_SH;    exception_source = `EXC_SH;    end
            `OP_SLTI        :   begin datapath = `DP_SLTI;  exception_source = `EXC_SLTI;  end
            `OP_SLTIU       :   begin datapath = `DP_SLTIU; exception_source = `EXC_SLTIU; end
            `OP_SW          :   begin datapath = `DP_SW;    exception_source = `EXC_SW;    end
            `OP_XORI        :   begin datapath = `DP_XORI;  exception_source = `EXC_XORI;  end
            default         :   begin datapath = `DP_NONE;  exception_source = `EXC_ADDU;  end
        endcase // case (opcode)
    end // always @ (*)
endmodule // antares_control_unit
