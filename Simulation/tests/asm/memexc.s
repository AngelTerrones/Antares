##############################################################################
# Filename      : musb-memexc.s
# Created On    : 2015-04-12
# Revision      : 0.1
# Author        : Angel Terrones
# Company       : Universidad Simón Bolívar
# Email         : aterrones@usb.ve
# Description   : Memory exception
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
    # Set a base address
    addiu       $3, $zero, 0x200

    addiu       $5, $zero, 255
    add         $6, $5, $5
    add         $7, $6, $6
    addiu       $8, $7, 30000

    # Place a test pattern in memory
    sw          $5, 0($3)
    sw          $6, 4($3)
    sw          $7, 8($3)
    sw          $8, 12($3)
    lw          $9,  1($3)  # BAD
    add         $6, $6, $9
    add         $7, $6, $6
    nop

    # End
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
