//==================================================================================================
//  Filename      : antares_branch_unit.v
//  Created On    : Fri Sep  4 21:35:54 2015
//  Last Modified : Sat Nov 07 11:49:10 2015
//  Revision      : 1.0
//  Author        : Angel Terrones
//  Company       : Universidad Simón Bolívar
//  Email         : aterrones@usb.ve
//
//  Description   : Branch target calculation
//==================================================================================================

`include "antares_defines.v"

module antares_branch_unit (
                            input [5:0]       opcode,            // Instruction opcode
                            input [31:0]      id_pc_add4,        // Instruction address + 4
                            input [31:0]      id_data_rs,        // Data from R0
                            input [31:0]      id_data_rt,        // Data from R1
                            input [25:0]      op_imm26,          // imm21/Imm16
                            output reg [31:0] pc_branch_address, // Destination address
                            output reg        id_take_branch     // Valid branch
                            ) ;

    //--------------------------------------------------------------------------
    // Signal Declaration: wire
    //--------------------------------------------------------------------------
    wire              beq;
    wire              bne;
    wire              bgez;
    wire              bgtz;
    wire              blez;
    wire              bltz;
    wire [31:0]       long_jump;
    wire [31:0]       short_jump;
    wire [5:0]        inst_function;
    wire [4:0]        op_rt;

    //--------------------------------------------------------------------------
    // assignments
    //--------------------------------------------------------------------------
    assign beq           = id_data_rs == id_data_rt;
    assign bne           = ~beq;
    assign bgez          = ~bltz;
    assign bgtz          = ~blez;
    assign blez          = bltz | ~(|id_data_rs);
    assign bltz          = id_data_rs[31];
    assign long_jump     = {id_pc_add4[31:28], op_imm26, 2'b00 };
    assign short_jump    = $signed(id_pc_add4) + $signed( { {14{op_imm26[15]}}, op_imm26[`ANTARES_INSTR_IMM16], 2'b00 } );
    assign inst_function = op_imm26[`ANTARES_INSTR_FUNCT];
    assign op_rt         = op_imm26[`ANTARES_INSTR_RT];

    //--------------------------------------------------------------------------
    // Get branch address
    //--------------------------------------------------------------------------
    always @(*) begin
        case (opcode)
            `OP_BEQ         : begin pc_branch_address = short_jump; id_take_branch = beq;  end
            `OP_BGTZ        : begin pc_branch_address = short_jump; id_take_branch = bgtz; end
            `OP_BLEZ        : begin pc_branch_address = short_jump; id_take_branch = blez; end
            `OP_BNE         : begin pc_branch_address = short_jump; id_take_branch = bne;  end
            `OP_J           : begin pc_branch_address = long_jump;  id_take_branch = 1'b1; end
            `OP_JAL         : begin pc_branch_address = long_jump;  id_take_branch = 1'b1; end
            `OP_TYPE_REGIMM : begin
                case (op_rt)
                    `RT_OP_BGEZ   : begin pc_branch_address = short_jump; id_take_branch = bgez; end
                    `RT_OP_BGEZAL : begin pc_branch_address = short_jump; id_take_branch = bgez; end
                    `RT_OP_BLTZ   : begin pc_branch_address = short_jump; id_take_branch = bltz; end
                    `RT_OP_BLTZAL : begin pc_branch_address = short_jump; id_take_branch = bltz; end
                    default       : begin pc_branch_address = 32'bx;    id_take_branch = 1'b0; end
                endcase // case (op_rt)
            end
            `OP_TYPE_R      : begin
                case(inst_function)
                    `FUNCTION_OP_JALR : begin pc_branch_address = id_data_rs; id_take_branch = 1'b1; end
                    `FUNCTION_OP_JR   : begin pc_branch_address = id_data_rs; id_take_branch = 1'b1; end
                    default           : begin pc_branch_address = 32'bx; id_take_branch = 1'b0; end
                endcase // case (inst_function)
            end
            default         : begin pc_branch_address = 32'bx; id_take_branch = 1'b0;    end
        endcase // case (opcode)
    end // always @ (*)
endmodule // antares_branch_unit
