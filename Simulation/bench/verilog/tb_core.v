//==================================================================================================
//  Filename      : tb_core.v
//  Created On    : Sun Sep  6 22:43:11 2015
//  Last Modified : Wed Sep 09 19:34:40 2015
//  Revision      : 1.0
//  Author        : Angel Terrones
//  Company       : Universidad Simón Bolívar
//  Email         : aterrones@usb.ve
//
//  Description   : Antares core testbench
//==================================================================================================

`include "antares_defines.v"

`timescale 1ns / 100ps

`define MEM_ADDR_WIDTH  12 // 2^(MEM_ADDR_WIDTH + 2) = 16 KB of memory

module tb_core;
    //--------------------------------------------------------------------------
    // wires
    //--------------------------------------------------------------------------
    wire            clk_core;
    wire            clk_bus;
    wire            rst;
    wire [31:0]     dport_address;
    wire [31:0]     dport_data_i;
    wire [31:0]     dport_data_o;
    wire            dport_enable;
    wire [3:0]      dport_wr;
    wire            dport_ready;
    wire            dport_error;

    wire [31:0]     iport_address;
    wire [31:0]     iport_data_i;
    wire            iport_enable;
    wire [3:0]      iport_wr;
    wire            iport_ready;
    wire            iport_error;
    wire            halted;

    //--------------------------------------------------------------------------
    // Assigns
    //--------------------------------------------------------------------------
    assign iport_error = 1'b0;          // No errors
    assign dport_error = 1'b0;          // No errors

    //--------------------------------------------------------------------------
    // MIPS CORE
    //--------------------------------------------------------------------------
    antares_core #(
                   .ENABLE_HW_MULT ( 1 ),
                   .ENABLE_HW_DIV  ( 1 ),
                   .ENABLE_HW_CLOZ ( 1 )
                   )
                   core(
                        // Outputs
                        .halted         ( halted              ),
                        .iport_address  ( iport_address[31:0] ),
                        .iport_wr       ( iport_wr[3:0]       ),
                        .iport_enable   ( iport_enable        ),
                        .dport_address  ( dport_address[31:0] ),
                        .dport_data_o   ( dport_data_o[31:0]  ),
                        .dport_wr       ( dport_wr[3:0]       ),
                        .dport_enable   ( dport_enable        ),
                        // Inputs
                        .clk            ( clk_core            ),
                        .rst            ( rst                 ),
                        .interrupts     ( 5'b0                ),    // No external interrupts.
                        .nmi            ( 1'b0                ),    // No external interrupts.
                        .iport_data_i   ( iport_data_i[31:0]  ),
                        .iport_ready    ( iport_ready         ),
                        .dport_data_i   ( dport_data_i[31:0]  ),
                        .dport_ready    ( dport_ready         ),
                        .iport_error    ( iport_error         ),
                        .dport_error    ( dport_error         )
                        );

    //--------------------------------------------------------------------------
    // Instruction/Data Memory
    // Port A = Instruccion
    // Port B = Data
    //--------------------------------------------------------------------------
    memory #(
             .MEM_ADDR_WIDTH( `MEM_ADDR_WIDTH )     // Memory size
             )
             memory0(
                     .clk        ( clk_bus                             ),
                     .rst        ( rst                                 ),
                     .a_addr     ( iport_address[2 +: `MEM_ADDR_WIDTH] ),    // instruction port
                     .a_din      ( 32'hB00B_B00B                       ),
                     .a_wr       ( iport_wr[3:0]                       ),
                     .a_enable   ( iport_enable                        ),
                     .a_dout     ( iport_data_i[31:0]                  ),
                     .a_ready    ( iport_ready                         ),
                     .b_addr     ( dport_address[2 +: `MEM_ADDR_WIDTH] ),    // data port
                     .b_din      ( dport_data_o[31:0]                  ),
                     .b_wr       ( dport_wr[3:0]                       ),
                     .b_enable   ( dport_enable                        ),
                     .b_dout     ( dport_data_i[31:0]                  ),
                     .b_ready    ( dport_ready                         )
                     );

    //--------------------------------------------------------------------------
    // Monitor
    //--------------------------------------------------------------------------
    monitor monitor0(
                     .halt                ( halted                           ),
                     .if_stall            ( core.if_stall                    ),
                     .if_flush            ( core.if_flush                    ),
                     .id_stall            ( core.id_stall                    ),
                     .id_flush            ( core.id_flush                    ),
                     .ex_stall            ( core.ex_stall                    ),
                     .ex_flush            ( core.ex_flush                    ),
                     .mem_stall           ( core.mem_stall                   ),
                     .mem_flush           ( core.mem_flush                   ),
                     .wb_stall            ( core.wb_stall                    ),
                     .mem_exception_pc    ( core.mem_exception_pc            ),
                     .id_instruction      ( core.id_instruction              ),
                     .wb_gpr_wa           ( core.wb_gpr_wa                   ),
                     .wb_gpr_wd           ( core.wb_gpr_wd                   ),
                     .wb_gpr_we           ( core.wb_gpr_we                   ),
                     .mem_address         ( core.mem_alu_result              ),
                     .mem_data            ( core.mem_mem_store_data          ),
                     .if_exception_ready  ( core.cpzero0.if_exception_ready  ),
                     .id_exception_ready  ( core.cpzero0.id_exception_ready  ),
                     .ex_exception_ready  ( core.cpzero0.ex_exception_ready  ),
                     .mem_exception_ready ( core.cpzero0.mem_exception_ready ),
                     .clk_core            ( clk_core                         ),
                     .clk_bus             ( clk_bus                          ),
                     .rst                 ( rst                              )
                     );
endmodule

// Local Variables:
// verilog-library-flags:("-y ../../../Hardware/ -y utils/")
// flycheck-verilator-include-path:("../../../Hardware/" "utils/")
// End:
