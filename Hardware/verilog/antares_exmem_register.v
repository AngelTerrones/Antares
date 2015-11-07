//==================================================================================================
//  Filename      : antares_exmem_register.v
//  Created On    : Sat Sep  5 21:23:28 2015
//  Last Modified : Sat Nov 07 12:04:18 2015
//  Revision      : 1.0
//  Author        : Angel Terrones
//  Company       : Universidad Simón Bolívar
//  Email         : aterrones@usb.ve
//
//  Description   : Pipeline register: EX -> MEM
//==================================================================================================

module antares_exmem_register (
                               input             clk,                      // main clock
                               input             rst,                      // main reset
                               input [31:0]      ex_alu_result,            // ALU result
                               input [31:0]      ex_mem_store_data,        // data to memory
                               input [4:0]       ex_gpr_wa,                // GPR write address
                               input             ex_gpr_we,                // GPR write enable
                               input             ex_mem_to_gpr_select,     // Select MEM/ALU to GPR
                               input             ex_mem_write,             // Mem write operation
                               input             ex_mem_byte,              // byte access
                               input             ex_mem_halfword,          // halfword access
                               input             ex_mem_data_sign_ext,     // Sign/Zero extend data from memory
                               input [31:0]      ex_exception_pc,
                               input             ex_movn,
                               input             ex_movz,
                               input             ex_b_is_zero,
                               input             ex_llsc,
                               input             ex_kernel_mode,
                               input             ex_is_bds,
                               input             ex_trap,
                               input             ex_trap_condition,
                               input             ex_mem_exception_source,  //
                               input             ex_flush,                 // clean
                               input             ex_stall,                 // stall EX stage
                               input             mem_stall,                // stall MEM stage
                               output reg [31:0] mem_alu_result,           // Same signals, but on mem stage
                               output reg [31:0] mem_mem_store_data,       //
                               output reg [4:0]  mem_gpr_wa,               //
                               output reg        mem_gpr_we,               //
                               output reg        mem_mem_to_gpr_select,    //
                               output reg        mem_mem_write,            //
                               output reg        mem_mem_byte,             //
                               output reg        mem_mem_halfword,         //
                               output reg        mem_mem_data_sign_ext,    //
                               output reg [31:0] mem_exception_pc,
                               output reg        mem_llsc,
                               output reg        mem_kernel_mode,
                               output reg        mem_is_bds,
                               output reg        mem_trap,
                               output reg        mem_trap_condition,
                               output reg        mem_mem_exception_source
                               );

    // Check for MOVN or MOVZ instruction
    wire    mov_reg_write = (ex_movn &  ~ex_b_is_zero) | (ex_movz &  ex_b_is_zero);

    //--------------------------------------------------------------------------
    // Propagate signals
    // Clear WE and Write signals only, on EX stall.
    //--------------------------------------------------------------------------
    always @(posedge clk) begin
        mem_alu_result           <= (rst) ? 32'b0 : ((mem_stall) ? mem_alu_result                                           : ex_alu_result);
        mem_mem_store_data       <= (rst) ? 32'b0 : ((mem_stall) ? mem_mem_store_data                                       : ex_mem_store_data);
        mem_gpr_wa               <= (rst) ? 5'b0  : ((mem_stall) ? mem_gpr_wa                                               : ex_gpr_wa);
        mem_gpr_we               <= (rst) ? 1'b0  : ((mem_stall) ? mem_gpr_we               : ((ex_stall | ex_flush) ? 1'b0 : ((ex_movz | ex_movn) ? mov_reg_write : ex_gpr_we)));
        mem_mem_to_gpr_select    <= (rst) ? 1'b0  : ((mem_stall) ? mem_mem_to_gpr_select    : ((ex_stall | ex_flush) ? 1'b0 : ex_mem_to_gpr_select));     // test
        mem_mem_write            <= (rst) ? 1'b0  : ((mem_stall) ? mem_mem_write            : ((ex_stall | ex_flush) ? 1'b0 : ex_mem_write));
        mem_mem_byte             <= (rst) ? 1'b0  : ((mem_stall) ? mem_mem_byte                                             : ex_mem_byte);
        mem_mem_halfword         <= (rst) ? 1'b0  : ((mem_stall) ? mem_mem_halfword                                         : ex_mem_halfword);
        mem_mem_data_sign_ext    <= (rst) ? 1'b0  : ((mem_stall) ? mem_mem_data_sign_ext                                    : ex_mem_data_sign_ext);
        mem_exception_pc         <= (rst) ? 32'b0 : ((mem_stall) ? mem_exception_pc                                         : ex_exception_pc);
        mem_llsc                 <= (rst) ? 1'b0  : ((mem_stall) ? mem_llsc                                                 : ex_llsc);
        mem_kernel_mode          <= (rst) ? 1'b0  : ((mem_stall) ? mem_kernel_mode                                          : ex_kernel_mode);
        mem_is_bds               <= (rst) ? 1'b0  : ((mem_stall) ? mem_is_bds                                               : ex_is_bds);
        mem_trap                 <= (rst) ? 1'b0  : ((mem_stall) ? mem_trap                 : ((ex_stall | ex_flush) ? 1'b0 : ex_trap));
        mem_trap_condition       <= (rst) ? 1'b0  : ((mem_stall) ? mem_trap_condition                                       : ex_trap_condition);
        mem_mem_exception_source <= (rst) ? 1'b0  : ((mem_stall) ? mem_mem_exception_source : ((ex_stall | ex_flush) ? 1'b0 : ex_mem_exception_source));
    end // always @ (posedge clk)
endmodule // antares_exmem_register
