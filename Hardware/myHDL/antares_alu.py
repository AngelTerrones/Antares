#!/usr/bin/env python
"""
Filename      : antares_alu.py
Revision      : 0.1
Author        : Angel Terrones
Email         : aterrones@usb.ve

Description   : Execution unit
"""

import random
from myhdl import Signal
from myhdl import always_comb
from myhdl import always
from myhdl import modbv
from myhdl import instance
from myhdl import delay
from myhdl import Simulation
from myhdl import StopSimulation
from myhdl import concat
from myhdl import traceSignals
from myhdl import toVerilog
import antares_defines


def antares_alu(clk,
                rst,
                ex_alu_port_a,
                ex_alu_port_b,
                ex_alu_operation,
                ex_stall,
                ex_flush,
                ex_request_stall,
                ex_alu_result,
                ex_b_is_zero,
                exc_overflow,
                enable_hw_mult=1,
                enable_hw_div=1,
                enable_hw_cloz=1):
    '''
    Ports:
    clk: System clock
    '''
    hilo = Signal(modbv(0)[64:])
    div_active = Signal(modbv(0)[1:])
    hilo_access = Signal(modbv(0)[1:])
    A = Signal(modbv(0)[32:])
    B = Signal(modbv(0)[32:])
    add_sub_result = Signal(modbv(0)[32:])  # Signed
    mult_result = Signal(modbv(0)[64:])
    hi = Signal(modbv(0)[32:])
    lo = Signal(modbv(0)[32:])
    shift_result = Signal(modbv(0)[632:])
    quotient = Signal(modbv(0)[32:])
    remainder = Signal(modbv(0)[32:])
    op_divs = Signal(modbv(0)[1:])
    op_divu = Signal(modbv(0)[1:])
    div_stall = Signal(modbv(0)[1:])
    dividend = Signal(modbv(0)[32:])
    divisor = Signal(modbv(0)[32:])
    enable_ex = Signal(modbv(0)[1:])
    op_mults = Signal(modbv(0)[1:])
    op_multu = Signal(modbv(0)[1:])
    mult_active = Signal(modbv(0)[1:])
    mult_ready = Signal(modbv(0)[1:])
    mult_stall = Signal(modbv(0)[1:])
    mult_input_a = Signal(modbv(0)[32:])
    mult_input_b = Signal(modbv(0)[32:])
    mult_signed_op = Signal(modbv(0)[1:])
    mult_enable_op = Signal(modbv(0)[1:])
    _op_divs = Signal(modbv(0)[1:])
    _op_divu = Signal(modbv(0)[1:])
    _op_mults = Signal(modbv(0)[1:])
    _op_multu = Signal(modbv(0)[1:])
    shift_input_data = Signal(modbv(0)[32:])
    shift_shmnt = Signal(modbv(0)[5:])
    shift_direction = Signal(modbv(0)[1:])
    shift_sign_extend = Signal(modbv(0)[1:])
    clo_result = Signal(modbv(0)[6:])
    clz_result = Signal(modbv(0)[6:])

    @always_comb
    def assignments_0():
        A.next = ex_alu_port_a
        B.next = ex_alu_port_b
        ex_b_is_zero.next = (B == 0)
        add_sub_result.next = (A + B) if (ex_alu_operation == antares_defines.ALU_OP_ADD or
                                          ex_alu_operation == antares_defines.ALU_OP_ADDU) else (A - B)
        hi.next = hilo[64:32]
        lo.next = hilo[32:0]
        enable_ex.next = ~(ex_stall ^ ex_request_stall) | ex_flush
        _op_divs.next = (B != 0) & (div_active == 0) & (ex_alu_operation == antares_defines.ALU_OP_DIV)
        _op_divu.next = (B != 0) & (div_active == 0) & (ex_alu_operation == antares_defines.ALU_OP_DIVU)
        _op_mults.next = (mult_active == 0) & (ex_alu_operation == antares_defines.ALU_OP_MULS)
        _op_multu.next = (mult_active == 0) & (ex_alu_operation == antares_defines.ALU_OP_MULU)
        op_divs.next = _op_divs & enable_ex
        op_divu.next = _op_divu & enable_ex
        op_mults.next = _op_mults & enable_ex
        op_multu.next = _op_multu & enable_ex
        # Request stall if: division, multiplication, and device unit is busy.
        # Do not use the op_XXX signal: combinatorial loop.
        ex_request_stall.next = (_op_divu | _op_divs | div_stall | _op_mults | _op_multu |
                                 (mult_active ^ mult_ready)) & hilo_access
        mult_stall.next = ex_stall ^ ex_request_stall
        mult_input_a.next = ex_alu_port_a[32:]
        mult_input_b.next = ex_alu_port_b[32:]
        mult_signed_op.next = ex_alu_operation == antares_defines.ALU_OP_MULS
        mult_enable_op.next = op_mults | op_multu
        shift_input_data.next = ex_alu_port_b
        shift_shmnt.next = ex_alu_port_b[5:]
        shift_direction.next = ex_alu_operation == antares_defines.ALU_OP_SLL
        shift_sign_extend.next = ex_alu_operation == antares_defines.ALU_OP_SRA
        dividend.next = ex_alu_port_a
        divisor.next = ex_alu_port_b

    @always_comb
    def multiplexer():
        if ex_alu_operation == antares_defines.ALU_OP_ADD:
            ex_alu_result.next = add_sub_result
        elif ex_alu_operation == antares_defines.ALU_OP_ADDU:
            ex_alu_result.next = add_sub_result
        elif ex_alu_operation == antares_defines.ALU_OP_SUB:
            ex_alu_result.next = add_sub_result
        elif ex_alu_operation == antares_defines.ALU_OP_SUBU:
            ex_alu_result.next = add_sub_result
        elif ex_alu_operation == antares_defines.ALU_OP_AND:
            ex_alu_result.next = ex_alu_port_a & ex_alu_port_b
        elif ex_alu_operation == antares_defines.ALU_OP_CLO:
            ex_alu_result.next = clo_result
        elif ex_alu_operation == antares_defines.ALU_OP_CLZ:
            ex_alu_result.next = clz_result
        elif ex_alu_operation == antares_defines.ALU_OP_NOR:
            ex_alu_result.next = ~(ex_alu_port_a | ex_alu_port_b)
        elif ex_alu_operation == antares_defines.ALU_OP_OR:
            ex_alu_result.next = ex_alu_port_a | ex_alu_port_b
        elif ex_alu_operation == antares_defines.ALU_OP_SLL:
            ex_alu_result.next = shift_result
        elif ex_alu_operation == antares_defines.ALU_OP_SRA:
            ex_alu_result.next = shift_result
        elif ex_alu_operation == antares_defines.ALU_OP_SRL:
            ex_alu_result.next = shift_result
        elif ex_alu_operation == antares_defines.ALU_OP_XOR:
            ex_alu_result.next = ex_alu_port_a ^ ex_alu_port_b
        elif ex_alu_operation == antares_defines.ALU_OP_MFHI:
            ex_alu_result.next = hi
        elif ex_alu_operation == antares_defines.ALU_OP_MFLO:
            ex_alu_result.next = lo
        elif ex_alu_operation == antares_defines.ALU_OP_SLT:
            ex_alu_result.next = ex_alu_port_a.signed() < ex_alu_port_b.signed()
        elif ex_alu_operation == antares_defines.ALU_OP_SLTU:
            ex_alu_result.next = ex_alu_port_a < ex_alu_port_b
        elif ex_alu_operation == antares_defines.ALU_OP_A:
            ex_alu_result.next = ex_alu_port_a
        elif ex_alu_operation == antares_defines.ALU_OP_B:
            ex_alu_result.next = ex_alu_port_b
        else:
            ex_alu_result.next = 0

    @always_comb
    def detect_overflow():
        if ex_alu_operation == antares_defines.ALU_OP_ADD:
            exc_overflow.next = (~(A[31] ^ B[31])) & (A[31] ^ add_sub_result[31])
        elif ex_alu_operation == antares_defines.ALU_OP_ADD:
            exc_overflow.next = (A[31] ^ B[31]) & (A[31] ^ add_sub_result[31])
        else:
            exc_overflow.next = 0

    @always(clk.posedge)
    def write_hilo():
        if rst == 1:
            hilo.next = 0
        elif (div_stall == 0) & (div_active == 1):
            hilo.next = concat(remainder, quotient)
        elif mult_ready == 1:
            if ex_alu_operation == antares_defines.ALU_OP_MULS:
                hilo.next = mult_result
            elif ex_alu_operation == antares_defines.ALU_OP_MULU:
                hilo.next = mult_result
            elif ex_alu_operation == antares_defines.ALU_OP_MADD:
                hilo.next = hilo + mult_result
            elif ex_alu_operation == antares_defines.ALU_OP_MADDU:
                hilo.next = hilo + mult_result
            elif ex_alu_operation == antares_defines.ALU_OP_MSUB:
                hilo.next = hilo - mult_result
            elif ex_alu_operation == antares_defines.ALU_OP_MSUBU:
                hilo.next = hilo - mult_result
            else:
                hilo.next = hilo
        elif enable_ex:
            if ex_alu_operation == antares_defines.ALU_OP_MTHI:
                hilo.next = concat(A, lo)
            elif ex_alu_operation == antares_defines.ALU_OP_MTLO:
                hilo.next = concat(hi, A)
            else:
                hilo.next = hilo

    @always(clk.posedge)
    def fsm_divider():
        if rst == 1:
            div_active.next = 0
        else:
            if div_active == 0:
                div_active.next = 1 if (op_divs | op_divu) else 0
            elif div_active == 1:
                div_active.next = 0 if (~div_stall) else 1

    @always_comb
    def hilo_access():
        if ex_alu_operation == antares_defines.ALU_OP_DIV:
            hilo_access.next = 1
        elif ex_alu_operation == antares_defines.ALU_OP_DIVU:
            hilo_access.next = 1
        elif ex_alu_operation == antares_defines.ALU_OP_MULS:
            hilo_access.next = 1
        elif ex_alu_operation == antares_defines.ALU_OP_MULU:
            hilo_access.next = 1
        elif ex_alu_operation == antares_defines.ALU_OP_MADD:
            hilo_access.next = 1
        elif ex_alu_operation == antares_defines.ALU_OP_MADDU:
            hilo_access.next = 1
        elif ex_alu_operation == antares_defines.ALU_OP_MSUB:
            hilo_access.next = 1
        elif ex_alu_operation == antares_defines.ALU_OP_MSUBU:
            hilo_access.next = 1
        elif ex_alu_operation == antares_defines.ALU_OP_MTHI:
            hilo_access.next = 1
        elif ex_alu_operation == antares_defines.ALU_OP_MTLO:
            hilo_access.next = 1
        elif ex_alu_operation == antares_defines.ALU_OP_MFHI:
            hilo_access.next = 1
        elif ex_alu_operation == antares_defines.ALU_OP_MFLO:
            hilo_access.next = 1
        else:
            hilo_access.next = 0

    # Instantiate modules

    return assignments_0, multiplexer, write_hilo, fsm_divider, always_comb


def testbench():
    '''
    '''
    clk = Signal(modbv(0)[1:])
    rst = Signal(modbv(1)[1:])

    dut = None

    halfperiod = delay(5)

    @always(halfperiod)
    def clk_drive():
        clk.next = not clk

    @instance
    def stimulus():
        yield delay(20)
        rst.next = 0
        print("Test")
        for i in range(10):
            print("Test {0}".i)

        print("Test: DONE.")
        raise StopSimulation

    return dut, clk_drive, stimulus


def main():
    # sim = Simulation(traceSignals(testbench))
    sim = Simulation(testbench())
    sim.run()


if __name__ == '__main__':
    main()

# Local Variables:
# flycheck-flake8-maximum-line-length: 120
# End:
