###############################################################################
# Filename      : musb-gpio.s
# Created On    : 2015-06-03
# Revision      : 0.1
# Author        : Angel Terrones
# Company       : Universidad Simón Bolívar
# Email         : aterrones@usb.ve
# Description   : gpio test
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
      la          $t0, 0x10000000         # gpio base address
      addiu       $t1, $zero, 0xFF        #

      # set direction
      sb          $zero, 4($t0)           # portA = input
      sb          $zero, 5($t0)           # portB = input
      sb          $t1, 6($t0)             # portC = output
      sb          $t1, 7($t0)             # portD = output

      # set edge polarity
      sb          $zero, 12($t0)          # port A: falling edge
      sb          $t1, 13($t0)            # port B: rising edge

      # clear interrupts
      sb          $zero, 16($t0)          # port A
      sb          $zero, 17($t0)          # port B

      # Enable interrutps (port)
      sb          $t1, 8($t0)             # port A
      sb          $t1, 9($t0)             # port B

      # Enable interrupts (CP0)
      mfc0        $t2, $12, 0
      ori         $t2, $t2, 0x0C01        # enable global interrupts & Interrpts 3, 2
      xori        $t2, $t2, 0x0004        # remove error level
      mtc0        $t2, $12, 0

      # wait for inputs (testbech)
      addu        $t2, $zero, $zero
      addiu       $t3, $zero, 2000
loop: addiu       $t2, $t2, 1
      sb          $t2, 2($t0)             # store counter to port C
      sb          $t2, 3($t0)             # store counter to port D
      bne         $t2, $t3, loop          # count up to 2000
      nop

      # end simulation/halt cpu
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
