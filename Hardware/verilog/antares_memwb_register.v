//==================================================================================================
//  Filename      : antares_memwb_register.v
//  Created On    : Sat Sep  5 21:41:57 2015
//  Last Modified : Sat Nov 07 12:10:59 2015
//  Revision      : 1.0
//  Author        : Angel Terrones
//  Company       : Universidad Simón Bolívar
//  Email         : aterrones@usb.ve
//
//  Description   : Pipeline register: MEM -> WB
//==================================================================================================

module antares_memwb_register (
                               input             clk,                   // main clock
                               input             rst,                   // main reset
                               input [31:0]      mem_read_data,         // data from Memory
                               input [31:0]      mem_alu_data,          // data from ALU
                               input [4:0]       mem_gpr_wa,            // GPR write enable
                               input             mem_mem_to_gpr_select, // select MEM/ALU to GPR
                               input             mem_gpr_we,            // GPR write enable
                               input             mem_flush,
                               input             mem_stall,             // stall MEM stage
                               input             wb_stall,              // stall WB stage
                               output reg [31:0] wb_read_data,          // data from Memory
                               output reg [31:0] wb_alu_data,           // data from ALU
                               output reg [4:0]  wb_gpr_wa,             // GPR write address
                               output reg        wb_mem_to_gpr_select,  // select MEM/ALU to GPR
                               output reg        wb_gpr_we              // GPR write enable
                               );

    //--------------------------------------------------------------------------
    // Propagate signals
    //--------------------------------------------------------------------------
    always @(posedge clk) begin
        wb_read_data         <= (rst) ? 32'b0 : ((wb_stall) ? wb_read_data                                           : mem_read_data);
        wb_alu_data          <= (rst) ? 32'b0 : ((wb_stall) ? wb_alu_data                                            : mem_alu_data);
        wb_gpr_wa            <= (rst) ? 5'b0  : ((wb_stall) ? wb_gpr_wa                                              : mem_gpr_wa);
        wb_mem_to_gpr_select <= (rst) ? 1'b0  : ((wb_stall) ? wb_mem_to_gpr_select                                   : mem_mem_to_gpr_select);
        wb_gpr_we            <= (rst) ? 1'b0  : ((wb_stall) ? wb_gpr_we            : ((mem_stall | mem_flush) ? 1'b0 : mem_gpr_we));
    end
endmodule // antares_memwb_register
