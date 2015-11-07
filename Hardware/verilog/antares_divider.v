//==================================================================================================
//  Filename      : antares_divider.v
//  Created On    : Thu Sep  3 08:41:07 2015
//  Last Modified : Sat Nov 07 12:01:42 2015
//  Revision      : 1.0
//  Author        : Angel Terrones
//  Company       : Universidad Simón Bolívar
//  Email         : aterrones@usb.ve
//
//  Description   : A multi-cycle divider unit.
//                  op_div and op_divu MUST BE dis-asserted after the setup
//                  cycle for normal operation, or the operation will be restarted.
//                  WARNING: no exception if divisor == 0.
//==================================================================================================

module antares_divider (
                        input         clk,
                        input         rst,
                        input         op_divs,
                        input         op_divu,
                        input [31:0]  dividend,
                        input [31:0]  divisor,
                        output [31:0] quotient,
                        output [31:0] remainder,
                        output        div_stall
                        );

    //--------------------------------------------------------------------------
    // Signal Declaration: reg
    //--------------------------------------------------------------------------
    reg           active;          // 1 while running
    reg           neg_result;      // 1 if the result must be negative
    reg           neg_remainder;   // 1 if the remainder must be negative
    reg [4:0]     cycle;           // number of cycles needed.
    reg [31:0]    result;          // Store the result.
    reg [31:0]    denominator;     // divisor
    reg [31:0]    residual;        // current remainder

    //--------------------------------------------------------------------------
    // Signal Declaration: wire
    //--------------------------------------------------------------------------
    wire [32:0]   partial_sub;        // temp

    //--------------------------------------------------------------------------
    // assignments
    //--------------------------------------------------------------------------
    assign quotient    = !neg_result ? result : -result;
    assign remainder   = !neg_remainder ? residual : -residual;
    assign div_stall   = active;
    assign partial_sub = {residual[30:0], result[31]} - denominator;            // calculate partial result

    //--------------------------------------------------------------------------
    // State Machine. This needs 32 cycles to calculate the result.
    // The result is loaded after 34 cycles
    // The first cycle is setup.
    //--------------------------------------------------------------------------
    always @(posedge clk) begin
        if (rst) begin
            /*AUTORESET*/
            // Beginning of autoreset for uninitialized flops
            active <= 1'h0;
            cycle <= 5'h0;
            denominator <= 32'h0;
            neg_result <= 1'h0;
            neg_remainder <= 1'h0;
            residual <= 32'h0;
            result <= 32'h0;
            // End of automatics
        end
        else begin
            if(op_divs) begin
                // Signed division.
                cycle         <= 5'd31;
                result        <= (dividend[31] == 1'b0) ? dividend : -dividend;
                denominator   <= (divisor[31] == 1'b0) ? divisor : -divisor;
                residual      <= 32'b0;
                neg_result    <= dividend[31] ^ divisor[31];
                neg_remainder <= dividend[31];
                active        <= 1'b1;
            end
            else if (op_divu) begin
                // Unsigned division.
                cycle         <= 5'd31;
                result        <= dividend;
                denominator   <= divisor;
                residual      <= 32'b0;
                neg_result    <= 1'b0;
                neg_remainder <= 1'h0;
                active        <= 1'b1;
            end
            else if (active) begin
                // run a iteration
                if(partial_sub[32] == 1'b0) begin
                    residual <= partial_sub[31:0];
                    result   <= {result[30:0], 1'b1};
                end
                else begin
                    residual <= {residual[30:0], result[31]};
                    result   <= {result[30:0], 1'b0};
                end

                if (cycle == 5'b0) begin
                    active <= 1'b0;
                end

                cycle <= cycle - 5'd1;
            end
        end
    end

endmodule // antares_divider
