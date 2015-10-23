#!/usr/bin/env python
"""
Filename      : antares_cloz.py
Revision      : 0.1
Author        : Angel Terrones
Email         : aterrones@usb.ve

Description   : Count leading ones/zeros.
"""

import random
from myhdl import Signal
from myhdl import always_comb
from myhdl import intbv
from myhdl import instance
from myhdl import delay
from myhdl import Simulation
from myhdl import StopSimulation
from myhdl import bin
from myhdl import downrange
from myhdl import toVerilog


def antares_shifter(A,
                    clo_result,
                    clz_result):

    @always_comb
    def clo():
        tmp = 32
        for i in downrange(32):
            if A[i] == 0:
                tmp = 31 - i
                break
        clo_result.next = tmp

    @always_comb
    def clz():
        tmp = 32
        for i in downrange(32):
            if A[i] == 1:
                tmp = 31 - i
                break
        clz_result.next = tmp

    return clo, clz


def testbench():
    '''
    CLO/CLZ using N 32-bit random inputs.
    '''
    A = Signal(intbv(0)[32:])
    clo_result = Signal(intbv(0)[6:])
    clz_result = Signal(intbv(0)[6:])
    dut = antares_shifter(A, clo_result, clz_result)
    toVerilog(antares_shifter, A, clo_result, clz_result)

    @instance
    def stimulus():
        for i in range(200):
            A.next = intbv(random.randint(0, 2**32))
            yield delay(10)
            ref = len(bin(A, width=32).split('0', 1)[0])
            if clo_result != ref:
                print("Error: I: {0} | CLO: {1} | Ref: {2}".format(bin(A, width=32),
                                                                   clo_result,
                                                                   ref))
            ref = len(bin(A, width=32).split('1', 1)[0])
            if clz_result != ref:
                print("Error: I: {0} | CLZ: {1} | Ref: {2}".format(bin(A, width=32),
                                                                   clz_result,
                                                                   ref))

        print("Test: DONE.")
        raise StopSimulation

    return dut, stimulus


def main():
    sim = Simulation(testbench())
    sim.run()


if __name__ == '__main__':
    main()

# Local Variables:
# flycheck-flake8-maximum-line-length: 120
# End:
