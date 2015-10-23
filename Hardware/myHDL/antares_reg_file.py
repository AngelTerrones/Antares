#!/usr/bin/env python
"""
Filename      : antares_reg_file.py
Revision      : 0.1
Author        : Angel Terrones
Email         : aterrones@usb.ve

Description   : 32 General Purpose Registers (GPR).
"""

import random
from myhdl import Signal
from myhdl import always
from myhdl import always_comb
from myhdl import intbv
from myhdl import instance
from myhdl import delay
from myhdl import Simulation
from myhdl import StopSimulation


def antares_reg_file(clk,
                     gpr_ra_a,
                     gpr_ra_b,
                     gpr_wa,
                     gpr_wd,
                     gpr_we,
                     gpr_rd_a,
                     gpr_rd_b):
    '''
    Register File.
    32 32-bit registers.
    Register 0 is always zero.
    '''
    registers = [Signal(intbv(random.randrange(0, 2**32))[32:]) for i in range(0, 32)]  # Create 31 registers.

    @always(clk.posedge)
    def write():
        if gpr_wa != 0 and gpr_we == 1:
            registers[gpr_wa].next = gpr_wd

    @always_comb
    def read():
        gpr_rd_a.next = registers[gpr_ra_a] if gpr_ra_a != 0 else 0
        gpr_rd_b.next = registers[gpr_ra_b] if gpr_ra_b != 0 else 0

    return write, read


def testbench():
    '''
    Write 32 random values, and read those values.
    Compare the data from portA and portB with the values
    stored in a temporal list. Print error in case of mismatch.
    '''
    # Signals.
    clk = Signal(intbv(0)[1:])
    gpr_ra_a = Signal(intbv(0)[5:])
    gpr_ra_b = Signal(intbv(0)[5:])
    gpr_wa = Signal(intbv(0)[5:])
    gpr_wd = Signal(intbv(0)[32:])
    gpr_we = Signal(intbv(0)[1:])
    gpr_rd_a = Signal(intbv(0)[32:])
    gpr_rd_b = Signal(intbv(0)[32:])

    values = [random.randrange(0, 2**32) for _ in range(32)]  # random values. Used as reference.

    dut = antares_reg_file(clk, gpr_ra_a, gpr_ra_b, gpr_wa, gpr_wd, gpr_we, gpr_rd_a, gpr_rd_b)

    @instance
    def stimulus():
        # write (random) data
        for i in range(32):
            gpr_wa.next = i
            gpr_wd.next = values[i]
            gpr_we.next = 1
            clk.next = 1
            yield delay(5)
            gpr_we.next = 0
            clk.next = 0
            yield delay(5)

        # read data, port A
        for i in range(32):
            gpr_ra_a.next = i
            clk.next = 1
            yield delay(5)
            clk.next = 0
            # Check if the value is ok
            if (i == 0 and gpr_rd_a != 0) or (i != 0 and gpr_rd_a != values[i]):
                print("ERROR at reg {0}: Value = {1}. Ref = {1}".format(i, gpr_rd_a, values[i]))
            yield delay(5)

        # read data, port B
        for i in range(32):
            gpr_ra_b.next = i
            clk.next = 1
            yield delay(5)
            clk.next = 0
            # Check if the value is ok
            if (i == 0 and gpr_rd_b != 0) or (i != 0 and gpr_rd_b != values[i]):
                print("ERROR at reg {0}: Value = {1}. Ref = {1}".format(i, gpr_rd_b, values[i]))
            yield delay(5)

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
