//==================================================================================================
//  Filename      : antares_alu.v
//  Created On    : Thu Sep  3 09:14:03 2015
//  Last Modified : Fri Sep 04 11:24:22 2015
//  Revision      : 1.0
//  Author        : Angel Terrones
//  Company       : Universidad Simón Bolívar
//  Email         : aterrones@usb.ve
//
//  Description   : The Execution unit.
//                  Performs the following operations:
//                  - Arithmetic
//                  - Logical
//                  - Shift
//                  - Comparison
//==================================================================================================

`include "antares_defines.v"

module antares_alu #(parameter ENABLE_HW_MULT = 1,
                     parameter ENABLE_HW_DIV  = 1,
                     parameter ENABLE_HW_CLOZ = 1)
    (/*AUTOARG*/
    // Outputs
    ex_request_stall, ex_alu_result, ex_b_is_zero, exc_overflow,
    // Inputs
    clk, rst, ex_alu_port_a, ex_alu_port_b, ex_alu_operation, ex_stall,
    ex_flush
    );

    input              clk;
    input              rst;
    input [31:0]       ex_alu_port_a;
    input [31:0]       ex_alu_port_b;
    input [4:0]        ex_alu_operation;
    input              ex_stall;
    input              ex_flush;
    output             ex_request_stall;
    output reg [31:0]  ex_alu_result;
    output             ex_b_is_zero;
    output reg         exc_overflow;

    //--------------------------------------------------------------------------
    // Signal Declaration: reg
    //--------------------------------------------------------------------------
    reg [63:0]         hilo; // hold the result from MULT instruction
    reg                div_active; // 1 if the divider is currently active.
    reg [5:0]          clo_result;
    reg [5:0]          clz_result;

    ///-------------------------------------------------------------------------
    // Signal Declaration: wire
    //--------------------------------------------------------------------------
    wire [31:0]        A;                // Port A (unsigned)
    wire [31:0]        B;                // Port B (unsigned)
    wire signed [31:0] add_sub_result;   // A+B or A - B
    wire [4:0]         ex_alu_operation; // Operation
    wire [63:0]        mult_result;      // Multiplication result
    wire [31:0]        hi;               // HILO[63:32]
    wire [31:0]        lo;               // HILO[31:0]
    wire [31:0]        shift_result;     // Shift result
    wire [31:0]        quotient;         // Division
    wire [31:0]        remainder;        // Division
    wire               op_divs;          // Signed division
    wire               op_divu;          // Unsigned division
    wire               div_stall;        // Stall
    wire [31:0]        dividend;
    wire [31:0]        divisor;
    wire               enable_ex;        // Enable operations

    wire               op_mults;         // Signed multiplication
    wire               op_multu;         // Unsigned multiplication
    wire               mult_active;      // Mult ex_alu_operation active inside the pipeline
    wire               mult_ready;       // Mult result ready
    wire               mult_stall;
    wire [31:0]        mult_input_a;
    wire [31:0]        mult_input_b;
    wire               mult_signed_op;
    wire               mult_enable_op;

    wire [31:0]        shift_input_data;
    wire [4:0]         shift_shamnt;
    wire               shift_direction;
    wire               shift_sign_extend;

    //--------------------------------------------------------------------------
    // assignments
    //--------------------------------------------------------------------------
    assign A                  = ex_alu_port_a;                                                  // unsigned
    assign B                  = ex_alu_port_b;                                                  // unsigned
    assign ex_b_is_zero       = (B == 32'b0);
    assign add_sub_result     = ((ex_alu_operation == `ALU_OP_ADD) | (ex_alu_operation == `ALU_OP_ADDU)) ? (A + B) : (A - B);
    assign hi                 = hilo[63:32];
    assign lo                 = hilo[31:0];
    assign enable_ex          = ~(ex_stall | ex_flush);
    assign op_divs            = (B != 32'd0) & (div_active == 1'b0) & (ex_alu_operation == `ALU_OP_DIV) & enable_ex;
    assign op_divu            = (B != 32'd0) & (div_active == 1'b0) & (ex_alu_operation == `ALU_OP_DIVU) & enable_ex;
    assign op_mults           = (mult_active == 1'b0) & (ex_alu_operation == `ALU_OP_MULS) & enable_ex;
    assign op_multu           = (mult_active == 1'b0) & (ex_alu_operation == `ALU_OP_MULU) & enable_ex;
    assign ex_request_stall   = ((op_divu | op_divs) | div_stall) | ((op_multu | op_mults) | (mult_active ^ mult_ready));
    assign mult_stall         = ex_stall;
    assign mult_input_a       = ex_alu_port_a[31:0];
    assign mult_input_b       = ex_alu_port_b[31:0];
    assign mult_signed_op     = ex_alu_operation == `ALU_OP_MULS;
    assign mult_enable_op     = op_mults | op_multu;
    assign shift_input_data   = ex_alu_port_b;
    assign shift_shamnt       = ex_alu_port_a[4:0];
    assign shift_direction    = ex_alu_operation == `ALU_OP_SLL;
    assign shift_sign_extend  = ex_alu_operation == `ALU_OP_SRA;
    assign dividend           = ex_alu_port_a[31:0];
    assign divisor            = ex_alu_port_b[31:0];

    //--------------------------------------------------------------------------
    // the BIG multiplexer
    //--------------------------------------------------------------------------
    always @(*) begin
        case(ex_alu_operation)
            `ALU_OP_ADD  : ex_alu_result = add_sub_result;
            `ALU_OP_ADDU : ex_alu_result = add_sub_result;
            `ALU_OP_SUB  : ex_alu_result = add_sub_result;
            `ALU_OP_SUBU : ex_alu_result = add_sub_result;
            `ALU_OP_AND  : ex_alu_result = ex_alu_port_a & ex_alu_port_b;
            `ALU_OP_CLO  : ex_alu_result = {26'b0, clo_result};
            `ALU_OP_CLZ  : ex_alu_result = {26'b0, clz_result};
            `ALU_OP_NOR  : ex_alu_result = ~(ex_alu_port_a | ex_alu_port_b);
            `ALU_OP_OR   : ex_alu_result = ex_alu_port_a | ex_alu_port_b;
            `ALU_OP_SLL  : ex_alu_result = shift_result;
            `ALU_OP_SRA  : ex_alu_result = shift_result;
            `ALU_OP_SRL  : ex_alu_result = shift_result;
            `ALU_OP_XOR  : ex_alu_result = ex_alu_port_a ^ ex_alu_port_b;
            `ALU_OP_MFHI : ex_alu_result = hi;
            `ALU_OP_MFLO : ex_alu_result = lo;
            `ALU_OP_SLT  : ex_alu_result = {31'b0, $signed(ex_alu_port_a) < $signed(ex_alu_port_b)};
            `ALU_OP_SLTU : ex_alu_result = {31'b0, ex_alu_port_a < ex_alu_port_b};
            `ALU_OP_A    : ex_alu_result = ex_alu_port_a;
            `ALU_OP_B    : ex_alu_result = ex_alu_port_b;
            default      : ex_alu_result = 32'bx;
        endcase // case (ex_alu_operation)
    end // always @ (*)

    //--------------------------------------------------------------------------
    // Detect Overflow
    //--------------------------------------------------------------------------
    always @(*) begin
        case (ex_alu_operation)
            `ALU_OP_ADD : exc_overflow = ((A[31] ~^ B[31]) & (A[31] ^ add_sub_result[31]));
            `ALU_OP_SUB : exc_overflow = ((A[31]  ^ B[31]) & (A[31] ^ add_sub_result[31]));
            default     : exc_overflow = 1'b0;
        endcase // case (ex_alu_operation)
    end

    //--------------------------------------------------------------------------
    // Write to HILO register
    // Div has priority over mult
    //
    // WARNING: THIS HAVE A BUG: HILO + X can't be done, unless the multiplier
    // has finished.
    // TODO: CHECK
    //--------------------------------------------------------------------------
    always @(posedge clk) begin
        if (rst) begin
            /*AUTORESET*/
            // Beginning of autoreset for uninitialized flops
            hilo <= 64'h0;
            // End of automatics
        end
        else if ((div_stall == 1'b0) & (div_active == 1'b1)) begin // Divider unit has finished.
            hilo <= {remainder, quotient};
        end
        else if(enable_ex & mult_ready) begin
            case (ex_alu_operation)
                `ALU_OP_MULS    : hilo <= mult_result;
                `ALU_OP_MULU    : hilo <= mult_result;
                `ALU_OP_MADD    : hilo <= hilo + mult_result;
                `ALU_OP_MADDU   : hilo <= hilo + mult_result;
                `ALU_OP_MSUB    : hilo <= hilo - mult_result;
                `ALU_OP_MSUBU   : hilo <= hilo - mult_result;
                default         : hilo <= hilo;
            endcase // case (ex_alu_operation)
        end // if (enable_ex & mult_ready)
        else if (enable_ex) begin
            case (ex_alu_operation)
                `ALU_OP_MTHI    : hilo <= {A, lo};
                `ALU_OP_MTLO    : hilo <= {hi, A};
                default         : hilo <= hilo;
            endcase // case (ex_alu_operation)
        end
    end // always @ (posedge clk)

    //--------------------------------------------------------------------------
    // Check if the div unit is currently active
    //--------------------------------------------------------------------------
    always @(posedge clk) begin
        if (rst) begin
            /*AUTORESET*/
            // Beginning of autoreset for uninitialized flops
            div_active <= 1'h0;
            // End of automatics
            div_active <= 1'b0;
        end
        else begin
            case(div_active)
                1'd0 : div_active <= (op_divs || op_divu) ? 1'b1 : 1'b0;
                1'd1 : div_active <= (~div_stall) ? 1'b0 : 1'b1;
            endcase // case (div_active)
        end // else: !if(rst)
    end // always @ (posedge clk)

    //--------------------------------------------------------------------------
    // Count Leading Ones/Zeros
    //--------------------------------------------------------------------------
    generate
        // Hardware CLO_CLZ
        if (ENABLE_HW_CLOZ) begin
            antares_cloz cloz(/*AUTOINST*/
                              // Outputs
                              .clo_result       (clo_result[5:0]),
                              .clz_result       (clz_result[5:0]),
                              // Inputs
                              .A                (A[31:0]));
        end
        // Disable
        else begin
            always begin
                clo_result = 6'dx;
                clz_result = 6'bx;
            end
        end // else: !if(ENABLE_HW_CLOZ)

    endgenerate

    //--------------------------------------------------------------------------
    // Shifter: instantiation
    //--------------------------------------------------------------------------
    antares_shifter shifter(/*AUTOINST*/
                            // Outputs
                            .shift_result       (shift_result[31:0]),
                            // Inputs
                            .shift_input_data   (shift_input_data[31:0]),
                            .shift_shamnt       (shift_shamnt[4:0]),
                            .shift_direction    (shift_direction),
                            .shift_sign_extend  (shift_sign_extend));

    //--------------------------------------------------------------------------
    // 32 x 32 bits multiplier: instantiation
    //--------------------------------------------------------------------------
    generate
        // Hardware multiplier
        if (ENABLE_HW_MULT) begin
            antares_multiplier mult(// Inputs
                                    .flush              (ex_flush),
                                    /*AUTOINST*/
                                    // Outputs
                                    .mult_result        (mult_result[63:0]),
                                    .mult_active        (mult_active),
                                    .mult_ready         (mult_ready),
                                    // Inputs
                                    .clk                (clk),
                                    .rst                (rst),
                                    .mult_input_a       (mult_input_a[31:0]),
                                    .mult_input_b       (mult_input_b[31:0]),
                                    .mult_signed_op     (mult_signed_op),
                                    .mult_enable_op     (mult_enable_op),
                                    .mult_stall         (mult_stall));
        end // if (ENABLE_HW_MULT)
        //  No hardware multiplier
        else begin
            assign mult_result  = 64'h0;    // disabled
            assign mult_active  = 1'b0;     // disabled
            assign mult_ready   = 1'b0;     // disabled
        end // else: !if(ENABLE_HW_MULT)
    endgenerate

    //--------------------------------------------------------------------------
    // instantiate the divider unit
    //--------------------------------------------------------------------------
    generate
        // Hardware divider
        if (ENABLE_HW_DIV) begin
            antares_divider divider(/*AUTOINST*/
                                    // Outputs
                                    .quotient           (quotient[31:0]),
                                    .remainder          (remainder[31:0]),
                                    .div_stall          (div_stall),
                                    // Inputs
                                    .clk                (clk),
                                    .rst                (rst),
                                    .op_divs            (op_divs),
                                    .op_divu            (op_divu),
                                    .dividend           (dividend[31:0]),
                                    .divisor            (divisor[31:0]));
        end // if (ENABLE_HW_DIV)
        // No hardware divider
        else begin
            assign quotient  = 32'h0;   // disabled
            assign remainder = 32'h0;   // disabled
            assign div_stall = 1'b0;    // disabled
        end // else: !if(ENABLE_HW_DIV)
    endgenerate

endmodule // antares_alu
