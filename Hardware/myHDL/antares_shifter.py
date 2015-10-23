#!/usr/bin/env python
"""
Filename      : antares_shifter.py
Revision      : 0.1
Author        : Angel Terrones
Email         : aterrones@usb.ve

Description   : Arithmetic/Logic shifter
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
from myhdl import concat
from myhdl import toVerilog


def antares_shifter(shift_input_data,
                    shift_shamnt,
                    shift_direction,
                    shift_sign_extend,
                    shift_result):
    '''
    32-bit shifter.
    Default: shift to right.
    Shift to left: invert bits, shift to right, invert bits again.

    Direction: 0 = right. 1 = left.
    '''

    input_inv = Signal(intbv(0, min=-(2**31), max=2**31))
    result_shift_temp = Signal(intbv(0, min=-(2**31), max=2**31))
    result_inv = Signal(intbv(0, min=-(2**31), max=2**31))

    operand = Signal(intbv(0, min=-(2**31), max=2**31))
    sign = Signal(intbv(0)[1:])

    @always_comb
    def output():
        shift_result.next = result_inv if shift_direction else result_shift_temp
        operand.next = input_inv if shift_direction else shift_input_data
        sign.next = shift_input_data[31] if (shift_sign_extend == 1 and shift_direction == 0) else False

    @always_comb
    def invert_input():
        tmp = intbv(0)[32:]
        for i in range(32):
            tmp[31 - i] = shift_input_data[i]
        input_inv.next = tmp.signed()

    @always_comb
    def invert_result():
        tmp = intbv(0)[32:]
        for i in range(32):
            tmp[31 - i] = result_shift_temp[i]
        result_inv.next = tmp.signed()

    @always_comb
    def sra():
        if shift_shamnt == 0:
            result_shift_temp.next = operand
        elif shift_shamnt == 1:
            result_shift_temp.next = concat(sign, operand[32:1]).signed()
        elif shift_shamnt == 2:
            result_shift_temp.next = concat(sign, operand[32:2]).signed()
        elif shift_shamnt == 3:
            result_shift_temp.next = concat(sign, operand[32:3]).signed()
        elif shift_shamnt == 4:
            result_shift_temp.next = concat(sign, operand[32:4]).signed()
        elif shift_shamnt == 5:
            result_shift_temp.next = concat(sign, operand[32:5]).signed()
        elif shift_shamnt == 6:
            result_shift_temp.next = concat(sign, operand[32:6]).signed()
        elif shift_shamnt == 7:
            result_shift_temp.next = concat(sign, operand[32:7]).signed()
        elif shift_shamnt == 8:
            result_shift_temp.next = concat(sign, operand[32:8]).signed()
        elif shift_shamnt == 9:
            result_shift_temp.next = concat(sign, operand[32:9]).signed()
        elif shift_shamnt == 10:
            result_shift_temp.next = concat(sign, operand[32:10]).signed()
        elif shift_shamnt == 11:
            result_shift_temp.next = concat(sign, operand[32:11]).signed()
        elif shift_shamnt == 12:
            result_shift_temp.next = concat(sign, operand[32:12]).signed()
        elif shift_shamnt == 13:
            result_shift_temp.next = concat(sign, operand[32:13]).signed()
        elif shift_shamnt == 14:
            result_shift_temp.next = concat(sign, operand[32:14]).signed()
        elif shift_shamnt == 15:
            result_shift_temp.next = concat(sign, operand[32:15]).signed()
        elif shift_shamnt == 16:
            result_shift_temp.next = concat(sign, operand[32:16]).signed()
        elif shift_shamnt == 17:
            result_shift_temp.next = concat(sign, operand[32:17]).signed()
        elif shift_shamnt == 18:
            result_shift_temp.next = concat(sign, operand[32:18]).signed()
        elif shift_shamnt == 19:
            result_shift_temp.next = concat(sign, operand[32:19]).signed()
        elif shift_shamnt == 20:
            result_shift_temp.next = concat(sign, operand[32:20]).signed()
        elif shift_shamnt == 21:
            result_shift_temp.next = concat(sign, operand[32:21]).signed()
        elif shift_shamnt == 22:
            result_shift_temp.next = concat(sign, operand[32:22]).signed()
        elif shift_shamnt == 23:
            result_shift_temp.next = concat(sign, operand[32:23]).signed()
        elif shift_shamnt == 24:
            result_shift_temp.next = concat(sign, operand[32:24]).signed()
        elif shift_shamnt == 25:
            result_shift_temp.next = concat(sign, operand[32:25]).signed()
        elif shift_shamnt == 26:
            result_shift_temp.next = concat(sign, operand[32:26]).signed()
        elif shift_shamnt == 27:
            result_shift_temp.next = concat(sign, operand[32:27]).signed()
        elif shift_shamnt == 28:
            result_shift_temp.next = concat(sign, operand[32:28]).signed()
        elif shift_shamnt == 29:
            result_shift_temp.next = concat(sign, operand[32:29]).signed()
        elif shift_shamnt == 30:
            result_shift_temp.next = concat(sign, operand[32:30]).signed()
        elif shift_shamnt == 31:
            result_shift_temp.next = concat(sign, operand[32:31]).signed()
        else:
            result_shift_temp.next = operand

    return invert_input, invert_result, sra, output


def testbench():
    '''
    Shift random values using a random ammount.
    Compares the result with a reference, and prints a error in case of mismatch.
    '''
    shift_input_data = Signal(intbv(0, min=-(2**31), max=2**31))
    shift_shamnt = Signal(intbv(0)[5:])
    shift_direction = Signal(intbv(0)[1:])
    shift_sign_extend = Signal(intbv(0)[1:])
    shift_result = Signal(intbv(0, min=-(2**31), max=2**31))

    dut = antares_shifter(shift_input_data, shift_shamnt, shift_direction, shift_sign_extend, shift_result)
    toVerilog(antares_shifter, shift_input_data, shift_shamnt, shift_direction, shift_sign_extend, shift_result)

    @instance
    def stimulus():
        for i in range(1000):
            shift_input_data.next = Signal(intbv(random.randint(-(2**31), 2**31)))
            shift_direction.next = Signal(intbv(random.randint(0, 1)))
            shift_sign_extend.next = Signal(intbv(random.randint(0, 1)))

            for j in range(32):
                shift_shamnt.next = Signal(intbv(j))
                yield delay(10)

                if shift_sign_extend == 0:
                    if shift_direction:
                        ref = (shift_input_data << shift_shamnt) & 0xFFFFFFFF
                    else:
                        ref = ((shift_input_data & 0xFFFFFFFF) >> shift_shamnt) & 0xFFFFFFFF

                    if ref != shift_result & 0xFFFFFFFF:
                        print("D: {0} | SE: {1} | Shamnt: {2} | O: {3} | Ref: {4}".format(shift_direction,
                                                                                          shift_sign_extend,
                                                                                          shift_shamnt,
                                                                                          bin(shift_result, width=32),
                                                                                          bin(ref, width=32)))
                if shift_sign_extend == 1:
                    if shift_direction:
                        ref = (shift_input_data << shift_shamnt) & 0xFFFFFFFF
                    else:
                        ref = (shift_input_data >> shift_shamnt) & 0xFFFFFFFF

                    if ref != shift_result & 0xFFFFFFFF:
                        print("D: {0} | SE: {1} | Shamnt: {2} | O: {3} | Ref: {4}".format(shift_direction,
                                                                                          shift_sign_extend,
                                                                                          shift_shamnt,
                                                                                          bin(shift_result, width=32),
                                                                                          bin(ref, width=32)))

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
