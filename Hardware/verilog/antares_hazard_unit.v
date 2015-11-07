//==================================================================================================
//  Filename      : antares_hazard_unit.v
//  Created On    : Fri Sep  4 22:32:20 2015
//  Last Modified : Sat Nov 07 12:03:58 2015
//  Revision      : 1.0
//  Author        : Angel Terrones
//  Company       : Universidad Simón Bolívar
//  Email         : aterrones@usb.ve
//
//  Description   : Hazard detection and pipeline control unit.
//==================================================================================================

`include "antares_defines.v"

module antares_hazard_unit (
                            input [7:0]  DP_Hazards,          //
                            input [4:0]  id_rs,               // Rs @ ID stage
                            input [4:0]  id_rt,               // Rt @ ID stage
                            input [4:0]  ex_rs,               // Rs @ EX stage
                            input [4:0]  ex_rt,               // Rt @ EX stage
                            input [4:0]  ex_gpr_wa,           // Write Address @ EX stage
                            input [4:0]  mem_gpr_wa,          // Write Address @ MEM stage
                            input [4:0]  wb_gpr_wa,           // Write Address @ WB stage
                            input        ex_gpr_we,           // GPR write enable @ EX
                            input        mem_gpr_we,          // GPR write enable @ MEM
                            input        wb_gpr_we,           // GPR write enable @ WB
                            input        mem_mem_write,       //
                            input        mem_mem_read,        //
                            input        ex_request_stall,    // Ex unit request a stall
                            input        dmem_request_stall,  // LSU: stall for Data access
                            input        imem_request_stall,  // LSU: stall for Instruction Fetch
                            input        if_exception_stall,  // Stall waiting for possible exception
                            input        id_exception_stall,  // Stall waiting for possible exception
                            input        ex_exception_stall,  // Stall waiting for possible exception
                            input        mem_exception_stall, //
                            output [1:0] forward_id_rs,       // Forwarding Rs multiplexer: Selector @ ID
                            output [1:0] forward_id_rt,       // Forwarding Rt multiplexer: Selector @ ID
                            output [1:0] forward_ex_rs,       // Forwarding Rs multiplexer: Selector @ EX
                            output [1:0] forward_ex_rt,       // Forwarding Rt multiplexer: Selector @ EX
                            output       if_stall,            // Stall pipeline register
                            output       id_stall,            // Stall pipeline register
                            output       ex_stall,            // Stall pipeline register
                            //output       ex_stall_unit;     // Stall the EX unit.
                            output       mem_stall,           // Stall pipeline register
                            output       wb_stall             // Stall pipeline register
                            );

    //--------------------------------------------------------------------------
    // Signal Declaration: wire
    //--------------------------------------------------------------------------
    // no forwarding if reading register zero
    wire         ex_wa_nz;
    wire         mem_wa_nz;
    wire         wb_wa_nz;
    // Need/Want signals
    wire         WantRsID;
    wire         WantRtID;
    wire         WantRsEX;
    wire         WantRtEX;
    wire         NeedRsID;
    wire         NeedRtID;
    wire         NeedRsEX;
    wire         NeedRtEX;
    // verify match: register address and write address (EX, MEM & WB)
    wire         id_ex_rs_match;
    wire         id_ex_rt_match;
    wire         id_mem_rs_match;
    wire         id_mem_rt_match;
    wire         id_wb_rs_match;
    wire         id_wb_rt_match;
    wire         ex_mem_rs_match;
    wire         ex_mem_rt_match;
    wire         ex_wb_rs_match;
    wire         ex_wb_rt_match;
    // stall signals
    wire         stall_id_1;
    wire         stall_id_2;
    wire         stall_id_3;
    wire         stall_id_4;
    wire         stall_ex_1;
    wire         stall_ex_2;

    // forward signals
    wire         forward_mem_id_rs;
    wire         forward_mem_id_rt;
    wire         forward_wb_id_rs;
    wire         forward_wb_id_rt;
    wire         forward_mem_ex_rs;
    wire         forward_mem_ex_rt;
    wire         forward_wb_ex_rs;
    wire         forward_wb_ex_rt;

    //--------------------------------------------------------------------------
    // assignments
    //--------------------------------------------------------------------------
    assign WantRsID = DP_Hazards[7];
    assign NeedRsID = DP_Hazards[6];
    assign WantRtID = DP_Hazards[5];
    assign NeedRtID = DP_Hazards[4];
    assign WantRsEX = DP_Hazards[3];
    assign NeedRsEX = DP_Hazards[2];
    assign WantRtEX = DP_Hazards[1];
    assign NeedRtEX = DP_Hazards[0];

    // Check if the register to use is $zero
    assign ex_wa_nz  = |(ex_gpr_wa);
    assign mem_wa_nz = |(mem_gpr_wa);
    assign wb_wa_nz  = |(wb_gpr_wa);

    // ID dependencies
    assign id_ex_rs_match  = (ex_wa_nz)  & (id_rs == ex_gpr_wa)  & (WantRsID | NeedRsID) & ex_gpr_we;
    assign id_ex_rt_match  = (ex_wa_nz)  & (id_rt == ex_gpr_wa)  & (WantRtID | NeedRtID) & ex_gpr_we;
    assign id_mem_rs_match = (mem_wa_nz) & (id_rs == mem_gpr_wa) & (WantRsID | NeedRsID) & mem_gpr_we;
    assign id_mem_rt_match = (mem_wa_nz) & (id_rt == mem_gpr_wa) & (WantRtID | NeedRtID) & mem_gpr_we;
    assign id_wb_rs_match  = (wb_wa_nz)  & (id_rs == wb_gpr_wa)  & (WantRsID | NeedRsID) & wb_gpr_we;
    assign id_wb_rt_match  = (wb_wa_nz)  & (id_rt == wb_gpr_wa)  & (WantRtID | NeedRtID) & wb_gpr_we;
    // EX dependencies
    assign ex_mem_rs_match = (mem_wa_nz) & (ex_rs == mem_gpr_wa) & (WantRsEX | NeedRsEX) & mem_gpr_we;
    assign ex_mem_rt_match = (mem_wa_nz) & (ex_rt == mem_gpr_wa) & (WantRtEX | NeedRtEX) & mem_gpr_we;
    assign ex_wb_rs_match  = (wb_wa_nz)  & (ex_rs == wb_gpr_wa)  & (WantRsEX | NeedRsEX) & wb_gpr_we;
    assign ex_wb_rt_match  = (wb_wa_nz)  & (ex_rt == wb_gpr_wa)  & (WantRtEX | NeedRtEX) & wb_gpr_we;

    // stall signals
    assign stall_id_1 = id_ex_rs_match & NeedRsID; // Needs data from EX (Rs)
    assign stall_id_2 = id_ex_rt_match & NeedRtID; // Needs data from EX (Rt)
    assign stall_id_3 = id_mem_rs_match & NeedRsID & (mem_mem_read | mem_mem_write); // Needs data from MEM (Rs)
    assign stall_id_4 = id_mem_rt_match & NeedRtID & (mem_mem_read | mem_mem_write); // Needs data from MEM (Rt)
    assign stall_ex_1 = ex_mem_rs_match & NeedRsEX & (mem_mem_read | mem_mem_write); // Needs data from MEM (Rs)
    assign stall_ex_2 = ex_mem_rt_match & NeedRtEX & (mem_mem_read | mem_mem_write); // Needs data from MEM (Rt)

    // forwarding signals
    assign forward_mem_id_rs = id_mem_rs_match & ~(mem_mem_read | mem_mem_write); // forward if not mem access
    assign forward_mem_id_rt = id_mem_rt_match & ~(mem_mem_read | mem_mem_write); // forward if not mem access;
    assign forward_wb_id_rs  = id_wb_rs_match;
    assign forward_wb_id_rt  = id_wb_rt_match;
    assign forward_mem_ex_rs = ex_mem_rs_match & ~(mem_mem_read | mem_mem_write);
    assign forward_mem_ex_rt = ex_mem_rt_match & ~(mem_mem_read | mem_mem_write);
    assign forward_wb_ex_rs  = ex_wb_rs_match;
    assign forward_wb_ex_rt  = ex_wb_rt_match;

    //--------------------------------------------------------------------------
    // Assign stall signals
    //--------------------------------------------------------------------------
    assign wb_stall  = mem_stall;
    assign mem_stall = dmem_request_stall | mem_exception_stall | if_stall; // check the if_stall
    assign ex_stall  = stall_ex_1 | stall_ex_2 | ex_exception_stall | ex_request_stall | mem_stall;
    assign id_stall  = stall_id_1 | stall_id_2 | stall_id_3 | stall_id_4 | id_exception_stall | ex_stall;
    assign if_stall  = imem_request_stall | if_exception_stall;

    //--------------------------------------------------------------------------
    // forwarding control signals
    //--------------------------------------------------------------------------
    // sel | ID stage           | EX stage
    //--------------------------------------------------------------------------
    // 00 -> ID (no forwarding) | EX (no forwarding)
    // 01 -> MEM                | MEM
    // 10 -> WB                 | WB
    // 11 -> don't care         | don't care
    //--------------------------------------------------------------------------
    assign forward_id_rs = (forward_mem_id_rs) ? 2'b01 : ((forward_wb_id_rs) ? 2'b10 : 2'b00);
    assign forward_id_rt = (forward_mem_id_rt) ? 2'b01 : ((forward_wb_id_rt) ? 2'b10 : 2'b00);
    assign forward_ex_rs = (forward_mem_ex_rs) ? 2'b01 : ((forward_wb_ex_rs) ? 2'b10 : 2'b00);
    assign forward_ex_rt = (forward_mem_ex_rt) ? 2'b01 : ((forward_wb_ex_rt) ? 2'b10 : 2'b00);
endmodule // antares_hazard_unit
