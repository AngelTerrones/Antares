#!/usr/bin/env python
"""
Filename      : antares_divider.py
Revision      : 0.1
Author        : Angel Terrones
Email         : aterrones@usb.ve

Description   : A multi-cycle divider.
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


def antares_divider(clk,
                    rst,
                    op_divs,
                    op_divu,
                    dividend,
                    divisor,
                    quotient,
                    remainder,
                    div_stall):
    '''
    Ports:

    clk: system clock
    rst: system reset
    op_divs: signed division
    op_divu: unsigned division
    dividend: input data
    divisor: input data
    quotient: output result
    remainder: output result
    div_stall: unit is busy

    WARNING: the op_divs/op_divu signal must be asserted only one cycle.
    Keeping it asserted for more than one cycle will restart the operation.
    The operation can be aborted by asserting the reset signal.
    '''
    active = Signal(modbv(0)[1:])
    neg_result = Signal(modbv(0)[1:])
    neg_remainder = Signal(modbv(0)[1:])
    cycle = Signal(modbv(0)[5:])
    result = Signal(modbv(0)[32:])
    denominator = Signal(modbv(0)[32:])
    residual = Signal(modbv(0)[32:])
    partial_sub = Signal(modbv(0)[33:])

    @always_comb
    def output():
        quotient.next = result if neg_result == 0 else -result
        remainder.next = residual if neg_remainder == 0 else -residual
        div_stall.next = active
        partial_sub.next = concat(residual[31:0], result[31]) - denominator

    @always(clk.posedge)
    def rtl():
        if rst == 1:
            active.next = 0
            cycle.next = 0
            denominator.next = 0
            neg_result.next = 0
            neg_remainder.next = 0
            residual.next = 0
            result.next = 0
        else:
            if op_divs:
                cycle.next = 31
                result.next = dividend if (dividend[31] == 0) else -dividend
                denominator.next = divisor if (divisor[31] == 0) else -divisor
                residual.next = 0
                neg_result.next = dividend[31] ^ divisor[31]
                neg_remainder.next = dividend[31]
                active.next = 1
            elif op_divu:
                cycle.next = 31
                result.next = dividend
                denominator.next = divisor
                residual.next = 0
                neg_result.next = 0
                neg_remainder.next = 0
                active.next = 1
            elif active:
                if partial_sub[32] == 0:
                    residual.next = partial_sub[32:0]
                    result.next = concat(result[31:0], modbv(1)[1:])
                else:
                    residual.next = concat(residual[31:0], result[31])
                    result.next = concat(result[31:0], modbv(0)[1:])

                if cycle == 0:
                    active.next = 0

                cycle.next = cycle - 1

    return output, rtl


def testbench():
    '''
    Performs N signed/unsigned operations, using random inputs.
    '''
    clk = Signal(modbv(0)[1:])
    rst = Signal(modbv(1)[1:])
    op_divs = Signal(modbv(0)[1:])
    op_divu = Signal(modbv(0)[1:])
    dividend = Signal(modbv(0)[32:])
    divisor = Signal(modbv(0)[32:])
    quotient = Signal(modbv(0)[32:])
    remainder = Signal(modbv(0)[32:])
    div_stall = Signal(modbv(0)[1:])

    dut = antares_divider(clk, rst, op_divs, op_divu, dividend, divisor,
                          quotient, remainder, div_stall)

    halfperiod = delay(5)

    @always(halfperiod)
    def clk_drive():
        clk.next = not clk

    @instance
    def stimulus():
        yield delay(200)
        rst.next = 0
        print("Testing unsigned division. Using 200 test cases")
        for i in range(100):
            yield clk.negedge
            dividend.next = Signal(modbv(random.randint(0, 2**32)))
            divisor.next = Signal(modbv(random.randint(0, 2**32)))
            op_divu.next = 1
            yield clk.negedge
            op_divu.next = 0
            yield div_stall.negedge
            yield delay(10)

            # Verification
            err1 = quotient != dividend // divisor
            err2 = remainder != dividend % divisor
            if err1 or err2:
                print("ERROR: {0}/{1} | Q: {2} | R: {3}".format(dividend,
                                                                divisor,
                                                                quotient,
                                                                remainder))
        print("Testing signed division. Using 200 test cases")
        for i in range(200):
            yield clk.negedge
            dividend.next = Signal(modbv(random.randint(0, 2**32)))
            divisor.next = Signal(modbv(random.randint(0, 2**32)))
            op_divs.next = 1
            yield clk.negedge
            op_divs.next = 0
            yield div_stall.negedge
            yield delay(10)

            # Verification
            err1 = quotient.signed() != int(dividend.signed() / divisor.signed())
            err2 = remainder.signed() != dividend.signed() - int(dividend.signed() / divisor.signed())*divisor.signed()
            if err1 or err2:
                print("ERROR: {0}/{1} | Q: {2} | R: {3}".format(dividend.signed(),
                                                                divisor.signed(),
                                                                quotient.signed(),
                                                                remainder.signed()))

        print("Test: DONE.")
        raise StopSimulation

    return dut, stimulus, clk_drive


def main():
    # sim = Simulation(traceSignals(testbench))
    sim = Simulation(testbench())
    sim.run()


if __name__ == '__main__':
    main()

# Local Variables:
# flycheck-flake8-maximum-line-length: 120
# End:
