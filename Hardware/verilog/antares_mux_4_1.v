//==================================================================================================
//  Filename      : antares_mux_4_1.v
//  Created On    : Mon Aug 31 23:14:22 2015
//  Last Modified : Sat Nov 07 12:14:18 2015
//  Revision      : 0.1
//  Author        : Angel Terrones
//  Company       : Universidad Simón Bolívar
//  Email         : aterrones@usb.ve
//
//  Description   : A 4-input multiplexer, with parameterizable width.
//==================================================================================================

module antares_mux_4_1 #(parameter WIDTH = 32)
    (
     input [1:0]            select,
     input [WIDTH-1:0]      in0,
     input [WIDTH-1:0]      in1,
     input [WIDTH-1:0]      in2,
     input [WIDTH-1:0]      in3,
     output reg [WIDTH-1:0] out
     );

    always @ ( /*AUTOSENSE*/in0 or in1 or in2 or in3 or select) begin
        case (select)
            2'b00: out = in0;
            2'b01: out = in1;
            2'b10: out = in2;
            2'b11: out = in3;
        endcase // case (select)
    end // always @ (...

endmodule // antares_mux_4_1
