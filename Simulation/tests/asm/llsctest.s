###############################################################################
# Filename      : musb-llsctest.s
# Created On    : 2015-04-12
# Revision      : 0.1
# Author        : Angel Terrones
# Company       : Universidad Simón Bolívar
# Email         : aterrones@usb.ve
# Description   : LL/SC test
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
      addi        $1, $0, 0
      addiu       $10, $0, 5
      addiu       $11, $10, 300
      addiu       $12, $0, 500
      addiu       $13, $12, 34
      addiu       $13, $13, 45

      sw          $11, 200($0)
      addi        $11, $0, 0
      nop
      nop
      nop

atomic_inc:
      ll          $20, 200($0)
      addiu       $21, $20, 1
      sc          $21, 200($0)
      beqz        $21, atomic_inc
      nop

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
