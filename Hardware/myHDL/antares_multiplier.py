#!/usr/bin/env python
"""
Filename      : antares_multiplier.py
Revision      : 0.1
Author        : Angel Terrones
Email         : aterrones@usb.ve

Description   : 32-bit x 32-bit multiplier
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


def antares_multiplier(clk,
                       rst,
                       mult_input_a,
                       mult_input_b,
                       mult_signed_op,
                       mult_enable_op,
                       mult_stall,
                       flush,
                       mult_result,
                       mult_active,
                       mult_ready):
    '''
    Ports:

    clk: System clock
    mult_input_a: input data
    mult_input_b: input data
    mult_signed_op: 0 = unsigned operation. 1 = signed operation
    mult_enable_op enable pipeline
    mult_stall: freeze the pipeline
    flush: flush the pipeline
    mult_result: 64-bit result
    mult_active: active operation
    mult_ready: Valid data on output port (mult_result)
    '''
    A = Signal(modbv(0)[33:])
    B = Signal(modbv(0)[33:])
    result_ll_0 = Signal(modbv(0)[32:])
    result_lh_0 = Signal(modbv(0)[32:])
    result_hl_0 = Signal(modbv(0)[32:])
    result_hh_0 = Signal(modbv(0)[32:])
    result_ll_1 = Signal(modbv(0)[32:])
    result_hh_1 = Signal(modbv(0)[32:])
    result_mid_1 = Signal(modbv(0)[33:])
    result_mult = Signal(modbv(0)[64:])
    active0 = Signal(modbv(0)[1:])
    active1 = Signal(modbv(0)[1:])
    active2 = Signal(modbv(0)[1:])
    active3 = Signal(modbv(0)[1:])
    sign_result0 = Signal(modbv(0)[1:])
    sign_result1 = Signal(modbv(0)[1:])
    sign_result2 = Signal(modbv(0)[1:])
    sign_result3 = Signal(modbv(0)[1:])
    sign_a = Signal(modbv(0)[1:])
    sign_b = Signal(modbv(0)[1:])
    partial_sum = Signal(modbv(0)[48:])
    a_sign_ext = Signal(modbv(0)[33:])
    b_sign_ext = Signal(modbv(0)[33:])

    @always_comb
    def assignments_0():
        sign_a.next = mult_input_a[31] if mult_signed_op else modbv(0)[1:]
        sign_b.next = mult_input_b[31] if mult_signed_op else modbv(0)[1:]
        partial_sum.next = concat(modbv(0)[16:], result_mid_1) + concat(result_hh_1[32:], result_ll_1[32:16])
        mult_result.next = -result_mult if sign_result3 else result_mult
        mult_ready.next = active3
        mult_active.next = active0 | active1 | active2 | active3

    @always_comb
    def assignments_1():
        a_sign_ext.next = concat(sign_a, mult_input_a)
        b_sign_ext.next = concat(sign_b, mult_input_b)

    @always(clk.posedge)
    def pipeline():
        if rst == 1 or flush == 1:
            A.next = modbv(0)[33:]
            B.next = modbv(0)[33:]
            active0.next = modbv(0)[1:]
            active1.next = modbv(0)[1:]
            active2.next = modbv(0)[1:]
            active3.next = modbv(0)[1:]
            result_hh_0.next = modbv(0)[31:]
            result_hh_1.next = modbv(0)[31:]
            result_hl_0.next = modbv(0)[31:]
            result_lh_0.next = modbv(0)[31:]
            result_ll_0.next = modbv(0)[31:]
            result_ll_1.next = modbv(0)[31:]
            result_mid_1.next = modbv(0)[31:]
            result_mult.next = modbv(0)[64:]
            sign_result0.next = modbv(0)[1:]
            sign_result1.next = modbv(0)[1:]
            sign_result2.next = modbv(0)[1:]
            sign_result3.next = modbv(0)[1:]
        elif not mult_stall:
            # fist stage
            A.next = -a_sign_ext if sign_a else a_sign_ext
            B.next = -b_sign_ext if sign_b else b_sign_ext
            sign_result0.next = sign_a ^ sign_b
            active0.next = mult_enable_op
            # second stage
            result_ll_0.next = A[16:0] * B[16:0]
            result_lh_0.next = A[16:0] * B[33:16]
            result_hl_0.next = A[33:16] * B[16:0]
            result_hh_0.next = A[32:16] * B[32:16]
            sign_result1.next = sign_result0
            active1.next = active0
            # third stage
            result_ll_1.next = result_ll_0
            result_hh_1.next = result_hh_0
            result_mid_1.next = result_lh_0 + result_hl_0
            sign_result2.next = sign_result1
            active2.next = active1
            # fourth stage
            result_mult.next = concat(partial_sum, result_ll_1[16:0])
            sign_result3.next = sign_result2
            active3.next = active2

    return assignments_0, assignments_1, pipeline


def testbench():
    '''
    Perform N signed/unsigned operations, using random inputs
    '''
    clk = Signal(modbv(0)[1:])
    rst = Signal(modbv(1)[1:])
    mult_input_a = Signal(modbv(0)[32:])
    mult_input_b = Signal(modbv(0)[32:])
    mult_signed_op = Signal(modbv(0)[1:])
    mult_enable_op = Signal(modbv(0)[1:])
    mult_stall = Signal(modbv(0)[1:])
    flush = Signal(modbv(0)[1:])
    mult_result = Signal(modbv(0)[64:])
    mult_active = Signal(modbv(0)[1:])
    mult_ready = Signal(modbv(0)[1:])

    dut = antares_multiplier(clk, rst, mult_input_a, mult_input_b, mult_signed_op, mult_enable_op, mult_stall, flush,
                             mult_result, mult_active, mult_ready)

    halfperiod = delay(5)

    @always(halfperiod)
    def clk_drive():
        clk.next = not clk

    @instance
    def stimulus():
        yield delay(20)
        rst.next = 0
        print("Testing unsigned division. Using 1000 test cases.")
        for i in range(1000):
            yield clk.negedge
            mult_input_a.next = Signal(modbv(random.randint(0, 2**32)))
            mult_input_b.next = Signal(modbv(random.randint(0, 2**32)))
            mult_enable_op.next = 1
            yield clk.negedge
            mult_enable_op.next = 0
            yield mult_ready.posedge
            yield delay(10)

            # Verification
            ref = mult_input_a * mult_input_b
            if mult_result != ref:
                print("ERROR: {0} * {1} = {2} | DUT: {3}".format(mult_input_a,
                                                                 mult_input_b,
                                                                 ref,
                                                                 mult_result))

        print("Testing signed division. Using 1000 test cases.")
        for i in range(1000):
            yield clk.negedge
            mult_input_a.next = Signal(modbv(random.randint(0, 2**32)))
            mult_input_b.next = Signal(modbv(random.randint(0, 2**32)))
            mult_enable_op.next = 1
            mult_signed_op.next = 1
            yield clk.negedge
            mult_enable_op.next = 0
            mult_signed_op.next = 0
            yield mult_ready.posedge
            yield delay(10)

            # Verification
            ref = mult_input_a.signed() * mult_input_b.signed()
            if mult_result.signed() != ref:
                print("ERROR: {0} * {1} = {2} | DUT: {3}".format(mult_input_a.signed(),
                                                                 mult_input_b.signed(),
                                                                 ref,
                                                                 mult_result.signed()))

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
