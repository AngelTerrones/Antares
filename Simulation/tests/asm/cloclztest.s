###############################################################################
# Filename      : musb-cloclztest.s
# Created On    : 2015-04-12
# Revision      : 0.1
# Author        : Angel Terrones
# Company       : Universidad Simón Bolívar
# Email         : aterrones@usb.ve
# Description   : CLO/CLZ test
###############################################################################

      .text
      .balign     4

# *************************************************
# Exception vector.
# DO NOT MODIFY
# *************************************************
      .ent        exception_vector
      .set        noreorder
exception_vector:
      j           mips32_general_exception      # jump to exception routine (general exception)
      nop
      .end        exception_vector

# *************************************************
# Exception vector.
# DO NOT MODIFY
# *************************************************
      .ent        interrupt_vector
interrupt_vector:
      j           mips32_interrupt_exception    # jump to exception routine (interrupts)
      nop
      .end        interrupt_vector

# *************************************************
# User Code Section
# This must be at 0x00000010 (reset boot address)
#
# Write your code HERE.
# *************************************************
      .ent        __start
__start:
    addiu       $1, $0, 10
    addiu       $2, $0, 5
	addiu       $3, $2, 300
	addiu       $4, $0, 500
	addiu       $5, $4, 34
	addiu       $5, $5,  45
	clz         $6, $2
	clz         $7, $3
	clz         $8, $4
	clz         $9, $5

    # negate
    addi        $1, $0, -1
    xor         $20, $2, $1
    xor         $21, $3, $1
    xor         $22, $4, $1
    xor         $23, $5, $1

    clo         $24, $20
    clo         $25, $21
    clo         $27, $22
    clo         $28, $23

    syscall
      .end        __start

# *************************************************
# General Exception
# *************************************************
      .global     mips32_general_exception
      .ent        mips32_general_exception
mips32_general_exception:
      # ------------------------------------------------------------------------
      # BEGIN MODIFY
      # ------------------------------------------------------------------------
      lui         $26, 0x0001
      mtc0        $26, $12, 0
dead0:
      j           dead0                   # Loop forever
      nop
      # ------------------------------------------------------------------------
      # END MODIFY
      # ------------------------------------------------------------------------
      .end        mips32_general_exception

# *************************************************
# "Special" Interrupt Vector.
#
# WARNING: Cause_IV must be set.
# *************************************************
      .ent        mips32_interrupt_exception
      .global     mips32_interrupt_exception
mips32_interrupt_exception:
      # ------------------------------------------------------------------------
      # BEGIN MODIFY
      # ------------------------------------------------------------------------
      lui         $26, 0x0001
      mtc0        $26, $12, 0
dead1:
      j           dead1                   # Loop forever
      nop
      # ------------------------------------------------------------------------
      # END MODIFY
      # ------------------------------------------------------------------------
      .end        mips32_interrupt_exception
