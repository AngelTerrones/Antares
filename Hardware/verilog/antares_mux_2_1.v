//==================================================================================================
//  Filename      : antares_mux_2_1.v
//  Created On    : Mon Aug 31 21:12:26 2015
//  Last Modified : Sat Nov 07 12:13:45 2015
//  Revision      : 0.1
//  Author        : Angel Terrones
//  Company       : Universidad Simón Bolívar
//  Email         : aterrones@usb.ve
//
//  Description   : A 2-input multiplexer, with parameterizable width
//==================================================================================================

module antares_mux_2_1 #(parameter WIDTH = 32)
    (
     input [WIDTH-1:0]      in0,
     input [WIDTH-1:0]      in1,
     input                  select,
     output reg [WIDTH-1:0] out
    );

    always @(/*AUTOSENSE*/in0 or in1 or select) begin
        case (select)
            1'b0: out = in0;
            1'b1: out = in1;
        endcase // case (select)
    end // always @ (...

endmodule // antares_mux_2_1
