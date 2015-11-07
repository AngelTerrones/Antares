//==================================================================================================
//  Filename      : antares_pc_register.v
//  Created On    : Tue Sep  1 10:21:01 2015
//  Last Modified : Sat Nov 07 12:14:50 2015
//  Revision      : 0.1
//  Author        : Angel Terrones
//  Company       : Universidad Simón Bolívar
//  Email         : aterrones@usb.ve
//
//  Description   : Program Counter (PC)
//==================================================================================================

`include "antares_defines.v"

module antares_pc_register (
                            input             clk,
                            input             rst,
                            input [31:0]      if_new_pc,
                            input             if_stall,
                            output reg [31:0] if_pc
                            );

    always @ ( posedge clk ) begin
        if_pc <= (rst) ? `ANTARES_VECTOR_BASE_RESET : ((if_stall) ? if_pc : if_new_pc);
    end

endmodule // antares_pc_register
