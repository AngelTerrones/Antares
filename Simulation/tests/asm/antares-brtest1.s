###############################################################################
# Filename      : musb-brtest1.s
# Created On    : 2015-04-12
# Revision      : 0.1
# Author        : Angel Terrones
# Company       : Universidad Simón Bolívar
# Email         : aterrones@usb.ve
# Description   : Branh Test 1
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
      addiu       $v0, $zero, 0xa
      # Set up some comparison values in registers
      addiu       $3, $zero, 1
      addiu       $4, $zero, -1
      # Checksum register
      addiu       $5, $zero, 0x1234
      # Test jump
      j           l_1
l_0:
      nop
      addu        $5, $5, $ra
      beq         $zero, $zero, l_2
l_1:
      nop
      addiu       $5, $5, 7
      jal         l_0
      nop
      nop
      j           l_8
l_2:
      nop
      addiu       $5, $5, 9
      bne         $3, $4, l_4
l_3:
      # Taken
      nop
      addiu       $5, $5, 5
      bgez        $zero, l_6
l_4:
      # Not taken
      nop
      addiu       $5, $5, 11
      blez        $3, l_3
l_5:
      # Taken
      nop
      addiu       $5, $5, 99
      bgtz        $3, l_3
l_6:
      # here
      nop
      addiu       $5, $5, 111
      jr          $ra
      # Should go to l_1, then go to l_8
l_7:
      # Should not get here
      nop
      addiu       $5, $5, 200
      syscall
l_8:
      nop
      addiu       $5, $5, 215
      jal l_10
l_9:
      # Should not get here
      nop
      addiu       $5, $5, 1
      syscall
l_10:
      nop
      addu        $5, $5, $5
      bltzal      $4, l_12
l_11:
        # Should not get here
      nop
      addiu       $5, $5, 400
      syscall
l_12:
      nop
      addu        $5, $5, $5
      bgezal      $4, l_11

l_13:
      nop
      addiu       $5, $5, 0xdead
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
