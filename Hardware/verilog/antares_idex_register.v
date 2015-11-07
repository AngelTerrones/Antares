//==================================================================================================
//  Filename      : antares_idex_register.v
//  Created On    : Sat Sep  5 21:08:59 2015
//  Last Modified : Sat Nov 07 12:09:34 2015
//  Revision      : 1.0
//  Author        : Angel Terrones
//  Company       : Universidad Simón Bolívar
//  Email         : aterrones@usb.ve
//
//  Description   : Pipeline register: ID -> EX
//==================================================================================================

module antares_idex_register (
                              input             clk,                     // Main clock
                              input             rst,                     // Main reset
                              input [4:0]       id_alu_operation,        // ALU operation from ID stage
                              input [31:0]      id_data_rs,              // Data Rs (forwarded)
                              input [31:0]      id_data_rt,              // Data Rt (forwarded)
                              input             id_gpr_we,               // GPR write enable
                              input             id_mem_to_gpr_select,    // Select MEM/ALU to GPR
                              input             id_mem_write,            // write to memory
                              input [1:0]       id_alu_port_a_select,    // Select: GPR, shamt, 0x00000004
                              input [1:0]       id_alu_port_b_select,    // Select: GPR, Imm16, PCAdd4
                              input [1:0]       id_gpr_wa_select,        // Select: direccion: Rt, Rd, $31
                              input             id_mem_byte,             // byte access
                              input             id_mem_halfword,         // halfword access
                              input             id_mem_data_sign_ext,    // Zero/Sign extend
                              input [4:0]       id_rs,                   // Rs
                              input [4:0]       id_rt,                   // Rt
                              input [3:0]       id_dp_hazard,
                              input             id_imm_sign_ext,         // extend the imm16
                              input [15:0]      id_sign_imm16,           // sign_ext(imm16)
                              input [31:0]      id_cp0_data,             //
                              input [31:0]      id_exception_pc,         // Current PC
                              input             id_movn,
                              input             id_movz,
                              input             id_llsc,
                              input             id_kernel_mode,
                              input             id_is_bds,
                              input             id_trap,
                              input             id_trap_condition,
                              input             id_ex_exception_source,
                              input             id_mem_exception_source,
                              input             id_flush,                // clean
                              input             id_stall,                // Stall ID stage
                              input             ex_stall,                // Stall EX stage
                              output reg [4:0]  ex_alu_operation,        // Same signals, but on EX stage
                              output reg [31:0] ex_data_rs,              //
                              output reg [31:0] ex_data_rt,              //
                              output reg        ex_gpr_we,               //
                              output reg        ex_mem_to_gpr_select,    //
                              output reg        ex_mem_write,            //
                              output reg [1:0]  ex_alu_port_a_select,    //
                              output reg [1:0]  ex_alu_port_b_select,    //
                              output reg [1:0]  ex_gpr_wa_select,        //
                              output reg        ex_mem_byte,             //
                              output reg        ex_mem_halfword,         //
                              output reg        ex_mem_data_sign_ext,    //
                              output reg [4:0]  ex_rs,                   //
                              output reg [4:0]  ex_rt,                   //
                              output reg [3:0]  ex_dp_hazard,
                              output reg [16:0] ex_sign_imm16,           //
                              output reg [31:0] ex_cp0_data,
                              output reg [31:0] ex_exception_pc,
                              output reg        ex_movn,
                              output reg        ex_movz,
                              output reg        ex_llsc,
                              output reg        ex_kernel_mode,
                              output reg        ex_is_bds,
                              output reg        ex_trap,
                              output reg        ex_trap_condition,
                              output reg        ex_ex_exception_source,
                              output reg        ex_mem_exception_source
                              );

    // sign extend the imm16
    wire [16:0] id_imm_extended = (id_imm_sign_ext) ? {id_sign_imm16[15], id_sign_imm16[15:0]} : {1'b0, id_sign_imm16};

    //--------------------------------------------------------------------------
    // Propagate signals
    // Clear only critical signals: op, WE, MEM write and Next PC
    //--------------------------------------------------------------------------
    always @(posedge clk) begin
        ex_alu_operation        <= (rst) ? 5'b0  : ((ex_stall & ~id_flush) ? ex_alu_operation        : ((id_stall | id_flush) ? 5'b0 : id_alu_operation));
        ex_data_rs              <= (rst) ? 32'b0 : ((ex_stall & ~id_flush) ? ex_data_rs                                              : id_data_rs);
        ex_data_rt              <= (rst) ? 32'b0 : ((ex_stall & ~id_flush) ? ex_data_rt                                              : id_data_rt);
        ex_gpr_we               <= (rst) ? 1'b0  : ((ex_stall & ~id_flush) ? ex_gpr_we               : ((id_stall | id_flush) ? 1'b0 : id_gpr_we));
        ex_mem_to_gpr_select    <= (rst) ? 1'b0  : ((ex_stall & ~id_flush) ? ex_mem_to_gpr_select    : ((id_stall | id_flush) ? 1'b0 : id_mem_to_gpr_select));
        ex_mem_write            <= (rst) ? 1'b0  : ((ex_stall & ~id_flush) ? ex_mem_write            : ((id_stall | id_flush) ? 1'b0 : id_mem_write));
        ex_alu_port_a_select    <= (rst) ? 2'b0  : ((ex_stall & ~id_flush) ? ex_alu_port_a_select                                    : id_alu_port_a_select);
        ex_alu_port_b_select    <= (rst) ? 2'b0  : ((ex_stall & ~id_flush) ? ex_alu_port_b_select                                    : id_alu_port_b_select);
        ex_gpr_wa_select        <= (rst) ? 2'b0  : ((ex_stall & ~id_flush) ? ex_gpr_wa_select                                        : id_gpr_wa_select);
        ex_mem_byte             <= (rst) ? 1'b0  : ((ex_stall & ~id_flush) ? ex_mem_byte                                             : id_mem_byte);
        ex_mem_halfword         <= (rst) ? 1'b0  : ((ex_stall & ~id_flush) ? ex_mem_halfword                                         : id_mem_halfword);
        ex_mem_data_sign_ext    <= (rst) ? 1'b0  : ((ex_stall & ~id_flush) ? ex_mem_data_sign_ext                                    : id_mem_data_sign_ext);
        ex_rs                   <= (rst) ? 5'b0  : ((ex_stall & ~id_flush) ? ex_rs                                                   : id_rs);
        ex_rt                   <= (rst) ? 5'b0  : ((ex_stall & ~id_flush) ? ex_rt                                                   : id_rt);
        ex_dp_hazard            <= (rst) ? 4'b0  : ((ex_stall & ~id_flush) ? ex_dp_hazard            : ((id_stall | id_flush) ? 4'b0 : id_dp_hazard));
        ex_sign_imm16           <= (rst) ? 17'b0 : ((ex_stall & ~id_flush) ? ex_sign_imm16                                           : id_imm_extended);
        ex_cp0_data             <= (rst) ? 32'b0 : ((ex_stall & ~id_flush) ? ex_cp0_data                                             : id_cp0_data);
        ex_exception_pc         <= (rst) ? 32'b0 : ((ex_stall & ~id_flush) ? ex_exception_pc                                         : id_exception_pc);
        ex_movn                 <= (rst) ? 1'b0  : ((ex_stall & ~id_flush) ? ex_movn                 : ((id_stall | id_flush) ? 1'b0 : id_movn));
        ex_movz                 <= (rst) ? 1'b0  : ((ex_stall & ~id_flush) ? ex_movz                 : ((id_stall | id_flush) ? 1'b0 : id_movz));
        ex_llsc                 <= (rst) ? 1'b0  : ((ex_stall & ~id_flush) ? ex_llsc                                                 : id_llsc);
        ex_kernel_mode          <= (rst) ? 1'b0  : ((ex_stall & ~id_flush) ? ex_kernel_mode                                          : id_kernel_mode);
        ex_is_bds               <= (rst) ? 1'b0  : ((ex_stall & ~id_flush) ? ex_is_bds                                               : id_is_bds);
        ex_trap                 <= (rst) ? 1'b0  : ((ex_stall & ~id_flush) ? ex_trap                 : ((id_stall | id_flush) ? 1'b0 : id_trap));
        ex_trap_condition       <= (rst) ? 1'b0  : ((ex_stall & ~id_flush) ? ex_trap_condition                                       : id_trap_condition);
        ex_ex_exception_source  <= (rst) ? 1'b0  : ((ex_stall & ~id_flush) ? ex_ex_exception_source  : ((id_stall | id_flush) ? 1'b0 : id_ex_exception_source));
        ex_mem_exception_source <= (rst) ? 1'b0  : ((ex_stall & ~id_flush) ? ex_mem_exception_source : ((id_stall | id_flush) ? 1'b0 : id_mem_exception_source));
    end // always @ (posedge clk)
endmodule // antares_idex_register
