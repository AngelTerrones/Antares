#!/usr/bin/env python
"""
Filename      : antares_mux_4_1.py
Revision      : 0.1
Author        : Angel Terrones
Email         : aterrones@usb.ve

Description   : A 4-input multiplexer.
"""

import random
from myhdl import Signal
from myhdl import always_comb
from myhdl import intbv
from myhdl import instance
from myhdl import delay
from myhdl import Simulation
from myhdl import toVerilog


def antares_mux_4_1(out, in0, in1, in2, in3, select):
    '''
    Multiplexer

    Ports
    -----
    out: Output
    in0: Input 0
    in1: Input 1
    in2: Input 2
    in3: Input 3
    select: Control input.
    '''

    @always_comb
    def mux_logic():
        if select == 0:
            out.next = in0
        elif select == 1:
            out.next = in1
        elif select == 2:
            out.next = in2
        elif select == 3:
            out.next = in3

    return mux_logic


def testbench():
    '''
    Testbench for the multiplexer 4 to 1.
    '''
    width = 32
    I0, I1, I2, I3 = [Signal(intbv(random.randint(0, 255))[width:]) for i in range(4)]
    O = Signal(intbv(0)[width:])
    S = Signal(intbv(0, min=0, max=4))

    dut = antares_mux_4_1(O, I0, I1, I2, I3, S)

    @instance
    def stimulus():
        while True:
            S.next = Signal(intbv(random.randint(0, 4))[2:])
            I0.next, I1.next, I2.next, I3.next = [Signal(intbv(random.randint(0, 255))[width:]) for i in range(4)]
            yield delay(5)
            print("Inputs: {0} {1} {2} {3} | Sel: {4} | Out: {5}".format(I0, I1, I2, I3, S, O))

    return dut, stimulus


def main():
    '''
    Main function.
    Runs the simulation.
    '''
    sim = Simulation(testbench())
    sim.run(100)


if __name__ == '__main__':
    main()

# Local Variables:
# flycheck-flake8-maximum-line-length: 120
# End:
