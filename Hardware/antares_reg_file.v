//==================================================================================================
//  Filename      : antares_reg_file.v
//  Created On    : Tue Sep  1 10:29:48 2015
//  Last Modified : Thu Sep 03 09:00:02 2015
//  Revision      : 1.0
//  Author        : Angel Terrones
//  Company       : Universidad Simón Bolívar
//  Email         : aterrones@usb.ve
//
//  Description   : 32 General Purpose Registers (GPR)
//                  WARNING: This register file DO NOT HAVE A RESET.
//==================================================================================================

module antares_reg_file (/*AUTOARG*/
    // Outputs
    gpr_rd_a, gpr_rd_b,
    // Inputs
    clk, gpr_ra_a, gpr_ra_b, gpr_wa, gpr_wd, gpr_we
    );

    input         clk;
    input [4:0]   gpr_ra_a;
    input [4:0]   gpr_ra_b;
    input [4:0]   gpr_wa;
    input [31:0]  gpr_wd;
    input         gpr_we;
    output [31:0] gpr_rd_a;
    output [31:0] gpr_rd_b;

    // Register file of 32 32-bit registers. Register 0 is always 0
    reg [31:0]    registers [1:31];

    // Clocked write
    always @ ( posedge clk ) begin
        if(gpr_wa != 5'b0)
          registers[gpr_wa] <= (gpr_we) ? gpr_wd :  registers[gpr_wa];
    end

    // Combinatorial read (no delay). Register 0 is read as 0 always.
    assign gpr_rd_a = (gpr_ra_a == 5'b0) ? 32'b0 : registers[gpr_ra_a];
    assign gpr_rd_b = (gpr_ra_b == 5'b0) ? 32'b0 : registers[gpr_ra_b];

endmodule // antares_reg_file
