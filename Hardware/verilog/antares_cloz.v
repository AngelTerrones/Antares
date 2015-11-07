//==================================================================================================
//  Filename      : antares_cloz.v
//  Created On    : Thu Sep  3 16:03:13 2015
//  Last Modified : Sat Nov 07 11:49:40 2015
//  Revision      : 1.0
//  Author        : Angel Terrones
//  Company       : Universidad Simón Bolívar
//  Email         : aterrones@usb.ve
//
//  Description   : Count leading ones/zeros unit.
//==================================================================================================

module antares_cloz (
                     input [31:0] A,
                     output [5:0] clo_result,
                     output [5:0] clz_result
                     );

    /*AUTOREG*/
    // Beginning of automatic regs (for this module's undeclared outputs)
    reg [5:0]           clo_result;
    reg [5:0]           clz_result;
    // End of automatics

    //--------------------------------------------------------------------------
    // Count Leading Ones
    //--------------------------------------------------------------------------
    always @(*) begin
        casez (A)
            32'b0zzz_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz : clo_result  = 6'd0;
            32'b10zz_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz : clo_result  = 6'd1;
            32'b110z_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz : clo_result  = 6'd2;
            32'b1110_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz : clo_result  = 6'd3;
            32'b1111_0zzz_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz : clo_result  = 6'd4;
            32'b1111_10zz_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz : clo_result  = 6'd5;
            32'b1111_110z_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz : clo_result  = 6'd6;
            32'b1111_1110_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz : clo_result  = 6'd7;
            32'b1111_1111_0zzz_zzzz_zzzz_zzzz_zzzz_zzzz : clo_result  = 6'd8;
            32'b1111_1111_10zz_zzzz_zzzz_zzzz_zzzz_zzzz : clo_result  = 6'd9;
            32'b1111_1111_110z_zzzz_zzzz_zzzz_zzzz_zzzz : clo_result  = 6'd10;
            32'b1111_1111_1110_zzzz_zzzz_zzzz_zzzz_zzzz : clo_result  = 6'd11;
            32'b1111_1111_1111_0zzz_zzzz_zzzz_zzzz_zzzz : clo_result  = 6'd12;
            32'b1111_1111_1111_10zz_zzzz_zzzz_zzzz_zzzz : clo_result  = 6'd13;
            32'b1111_1111_1111_110z_zzzz_zzzz_zzzz_zzzz : clo_result  = 6'd14;
            32'b1111_1111_1111_1110_zzzz_zzzz_zzzz_zzzz : clo_result  = 6'd15;
            32'b1111_1111_1111_1111_0zzz_zzzz_zzzz_zzzz : clo_result  = 6'd16;
            32'b1111_1111_1111_1111_10zz_zzzz_zzzz_zzzz : clo_result  = 6'd17;
            32'b1111_1111_1111_1111_110z_zzzz_zzzz_zzzz : clo_result  = 6'd18;
            32'b1111_1111_1111_1111_1110_zzzz_zzzz_zzzz : clo_result  = 6'd19;
            32'b1111_1111_1111_1111_1111_0zzz_zzzz_zzzz : clo_result  = 6'd20;
            32'b1111_1111_1111_1111_1111_10zz_zzzz_zzzz : clo_result  = 6'd21;
            32'b1111_1111_1111_1111_1111_110z_zzzz_zzzz : clo_result  = 6'd22;
            32'b1111_1111_1111_1111_1111_1110_zzzz_zzzz : clo_result  = 6'd23;
            32'b1111_1111_1111_1111_1111_1111_0zzz_zzzz : clo_result  = 6'd24;
            32'b1111_1111_1111_1111_1111_1111_10zz_zzzz : clo_result  = 6'd25;
            32'b1111_1111_1111_1111_1111_1111_110z_zzzz : clo_result  = 6'd26;
            32'b1111_1111_1111_1111_1111_1111_1110_zzzz : clo_result  = 6'd27;
            32'b1111_1111_1111_1111_1111_1111_1111_0zzz : clo_result  = 6'd28;
            32'b1111_1111_1111_1111_1111_1111_1111_10zz : clo_result  = 6'd29;
            32'b1111_1111_1111_1111_1111_1111_1111_110z : clo_result  = 6'd30;
            32'b1111_1111_1111_1111_1111_1111_1111_1110 : clo_result  = 6'd31;
            32'b1111_1111_1111_1111_1111_1111_1111_1111 : clo_result  = 6'd32;
            default : clo_result                                      = 6'd0;
        endcase // casez (A)
    end // always @ (*)

    //--------------------------------------------------------------------------
    // Count Leading Zeros
    //--------------------------------------------------------------------------
    always @(*) begin
        casez (A)
            32'b1zzz_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz : clz_result  = 6'd0;
            32'b01zz_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz : clz_result  = 6'd1;
            32'b001z_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz : clz_result  = 6'd2;
            32'b0001_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz : clz_result  = 6'd3;
            32'b0000_1zzz_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz : clz_result  = 6'd4;
            32'b0000_01zz_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz : clz_result  = 6'd5;
            32'b0000_001z_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz : clz_result  = 6'd6;
            32'b0000_0001_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz : clz_result  = 6'd7;
            32'b0000_0000_1zzz_zzzz_zzzz_zzzz_zzzz_zzzz : clz_result  = 6'd8;
            32'b0000_0000_01zz_zzzz_zzzz_zzzz_zzzz_zzzz : clz_result  = 6'd9;
            32'b0000_0000_001z_zzzz_zzzz_zzzz_zzzz_zzzz : clz_result  = 6'd10;
            32'b0000_0000_0001_zzzz_zzzz_zzzz_zzzz_zzzz : clz_result  = 6'd11;
            32'b0000_0000_0000_1zzz_zzzz_zzzz_zzzz_zzzz : clz_result  = 6'd12;
            32'b0000_0000_0000_01zz_zzzz_zzzz_zzzz_zzzz : clz_result  = 6'd13;
            32'b0000_0000_0000_001z_zzzz_zzzz_zzzz_zzzz : clz_result  = 6'd14;
            32'b0000_0000_0000_0001_zzzz_zzzz_zzzz_zzzz : clz_result  = 6'd15;
            32'b0000_0000_0000_0000_1zzz_zzzz_zzzz_zzzz : clz_result  = 6'd16;
            32'b0000_0000_0000_0000_01zz_zzzz_zzzz_zzzz : clz_result  = 6'd17;
            32'b0000_0000_0000_0000_001z_zzzz_zzzz_zzzz : clz_result  = 6'd18;
            32'b0000_0000_0000_0000_0001_zzzz_zzzz_zzzz : clz_result  = 6'd19;
            32'b0000_0000_0000_0000_0000_1zzz_zzzz_zzzz : clz_result  = 6'd20;
            32'b0000_0000_0000_0000_0000_01zz_zzzz_zzzz : clz_result  = 6'd21;
            32'b0000_0000_0000_0000_0000_001z_zzzz_zzzz : clz_result  = 6'd22;
            32'b0000_0000_0000_0000_0000_0001_zzzz_zzzz : clz_result  = 6'd23;
            32'b0000_0000_0000_0000_0000_0000_1zzz_zzzz : clz_result  = 6'd24;
            32'b0000_0000_0000_0000_0000_0000_01zz_zzzz : clz_result  = 6'd25;
            32'b0000_0000_0000_0000_0000_0000_001z_zzzz : clz_result  = 6'd26;
            32'b0000_0000_0000_0000_0000_0000_0001_zzzz : clz_result  = 6'd27;
            32'b0000_0000_0000_0000_0000_0000_0000_1zzz : clz_result  = 6'd28;
            32'b0000_0000_0000_0000_0000_0000_0000_01zz : clz_result  = 6'd29;
            32'b0000_0000_0000_0000_0000_0000_0000_001z : clz_result  = 6'd30;
            32'b0000_0000_0000_0000_0000_0000_0000_0001 : clz_result  = 6'd31;
            32'b0000_0000_0000_0000_0000_0000_0000_0000 : clz_result  = 6'd32;
            default : clz_result                                      = 6'd0;
        endcase // casez (A)
    end // always @ (*)
endmodule // antares_cloz
