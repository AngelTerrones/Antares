//==================================================================================================
//  Filename      : antares_multiplier.v
//  Created On    : Wed Sep  2 22:05:36 2015
//  Last Modified : Sat Nov 07 12:11:51 2015
//  Revision      : 1.0
//  Author        : Angel Terrones
//  Company       : Universidad Simón Bolívar
//  Email         : aterrones@usb.ve
//
//  Description   : 32 x 32 pipelined multiplier.
//                  For signed operations: invert, perform unsigned mult, set result sign.
//==================================================================================================

module antares_multiplier(
                          input         clk,            // clock
                          input         rst,            // reset
                          input [31:0]  mult_input_a,   // Data
                          input [31:0]  mult_input_b,   // Data
                          input         mult_signed_op, // Unsigned (0) or signed operation (1)
                          input         mult_enable_op, // Signal a valid operation
                          input         mult_stall,     // Freeze the pipeline
                          input         flush,          // Flush the pipeline
                          output [63:0] mult_result,    // Result
                          output        mult_active,    // Active operations @ pipeline
                          output        mult_ready      // Valid data on output port (result)
                          );

    //--------------------------------------------------------------------------
    // Signal Declaration: reg
    //--------------------------------------------------------------------------
    reg [32:0]    A;
    reg [32:0]    B;
    reg [31:0]    result_ll_0;
    reg [31:0]    result_lh_0;
    reg [31:0]    result_hl_0;
    reg [31:0]    result_hh_0; // keep only 32 bits (ISE Warning)
    reg [31:0]    result_ll_1;
    reg [31:0]    result_hh_1; // keep only 32 bits (ISE Warning)
    reg [32:0]    result_mid_1;
    reg [63:0]    result_mult;

    reg           active0;     // Pipeline the enable signal, so HDU can know if a valid operation is in the pipeline
    reg           active1;
    reg           active2;
    reg           active3;
    reg           sign_result0;
    reg           sign_result1;
    reg           sign_result2;
    reg           sign_result3;

    ///-------------------------------------------------------------------------
    // Signal Declaration: wire
    //--------------------------------------------------------------------------
    wire          sign_a;
    wire          sign_b;
    wire [47:0]   partial_sum;
    wire [32:0]   a_sign_ext;
    wire [32:0]   b_sign_ext;

    //--------------------------------------------------------------------------
    // assignments
    //--------------------------------------------------------------------------
    assign sign_a      = (mult_signed_op) ? mult_input_a[31] : 1'b0;
    assign sign_b      = (mult_signed_op) ? mult_input_b[31] : 1'b0;
    assign a_sign_ext  = {sign_a, mult_input_a};
    assign b_sign_ext  = {sign_b, mult_input_b};
    assign partial_sum = {15'b0, result_mid_1} + {result_hh_1[31:0], result_ll_1[31:16]};
    assign mult_result = (sign_result3) ? -result_mult : result_mult;                         // Set true sign.
    assign mult_ready  = active3;
    assign mult_active = active0 | active1 | active2 | active3;                             // 4th stage holds the result

    //--------------------------------------------------------------------------
    // Implement the pipeline
    //--------------------------------------------------------------------------
    always @(posedge clk) begin
        if (rst | flush) begin
            /*AUTORESET*/
            // Beginning of autoreset for uninitialized flops
            A <= 33'h0;
            B <= 33'h0;
            active0 <= 1'h0;
            active1 <= 1'h0;
            active2 <= 1'h0;
            active3 <= 1'h0;
            result_hh_0 <= 32'h0;
            result_hh_1 <= 32'h0;
            result_hl_0 <= 32'h0;
            result_lh_0 <= 32'h0;
            result_ll_0 <= 32'h0;
            result_ll_1 <= 32'h0;
            result_mid_1 <= 33'h0;
            result_mult <= 64'h0;
            sign_result0 <= 1'h0;
            sign_result1 <= 1'h0;
            sign_result2 <= 1'h0;
            sign_result3 <= 1'h0;
            // End of automatics
        end
        else if(~mult_stall) begin
            // --- first stage
            // Change sign. Perform unsigned multiplication. Save the result sign.
            A            <= sign_a ? -a_sign_ext : a_sign_ext;
            B            <= sign_b ? -b_sign_ext : b_sign_ext;
            sign_result0 <= sign_a ^ sign_b;
            active0      <= mult_enable_op;
            // --- second stage
            result_ll_0  <= A[15:0]  *  B[15:0];       // 16 x 16
            result_lh_0  <= A[15:0]  *  B[32:16];      // 16 x 17
            result_hl_0  <= A[32:16] *  B[15:0];       // 17 x 16
            result_hh_0  <= A[31:16] *  B[31:16];      // 16 x 16
            sign_result1 <= sign_result0;
            active1      <= active0;
            // --- third stage
            result_ll_1  <= result_ll_0;
            result_hh_1  <= result_hh_0;
            result_mid_1 <= result_lh_0 + result_hl_0;      // sum mid
            sign_result2 <= sign_result1;
            active2      <= active1;
            // -- fourth stage
            result_mult  <= {partial_sum, result_ll_1[15:0]};
            sign_result3 <= sign_result2;
            active3      <= active2;
        end
    end

endmodule
