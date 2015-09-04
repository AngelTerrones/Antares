//==================================================================================================
//  Filename      : antares_add.v
//  Created On    : Tue Sep  1 10:15:22 2015
//  Last Modified : Thu Sep 03 08:58:33 2015
//  Revision      : 0.1
//  Author        : Angel Terrones
//  Company       : Universidad Simón Bolívar
//  Email         : aterrones@usb.ve
//
//  Description   : A simple 32-bits adder
//==================================================================================================

module antares_add (/*AUTOARG*/
    // Outputs
    c,
    // Inputs
    a, b
    );

    input [31:0]  a;
    input [31:0]  b;
    output [31:0] c;

    assign c = a + b;

endmodule // antares_add
