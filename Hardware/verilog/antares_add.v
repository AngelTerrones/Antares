//==================================================================================================
//  Filename      : antares_add.v
//  Created On    : Tue Sep  1 10:15:22 2015
//  Last Modified : Sat Nov 07 11:45:24 2015
//  Revision      : 0.1
//  Author        : Angel Terrones
//  Company       : Universidad Simón Bolívar
//  Email         : aterrones@usb.ve
//
//  Description   : A simple 32-bits adder
//==================================================================================================

module antares_add (
                    input [31:0]  a,
                    input [31:0]  b,
                    output [31:0] c
                    );


    assign c = a + b;

endmodule // antares_add
