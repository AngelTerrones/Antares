###############################################################################
# Filename      : musb-memtest1.s
# Created On    : 2015-04-12
# Revision      : 0.1
# Author        : Angel Terrones
# Company       : Universidad Simón Bolívar
# Email         : aterrones@usb.ve
# Description   : Memory test 1
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
      #;;  Set a base address
      addiu       $3, $zero, 0x200

      addiu       $5, $zero, 0xcafe
      addiu       $6, $zero, 0xfeca
      addiu       $7, $zero, 0xbeef
      addiu       $8, $zero, 0xefbe

      #;; Place a test pattern in memory
      sb          $5, 0($3)
      sb          $6, 1($3)
      sb          $7, 6($3)
      sb          $8, 7($3)

      lbu         $9,  0($3)
      lbu         $10, 1($3)
      lb          $11, 6($3)
      lb          $12, 7($3)

      addiu       $3, $3, 4
      sh          $5, 0($3)
      sh          $6, 2($3)
      sh          $7, 4($3)
      sh          $8, 6($3)

      lhu         $13,  0($3)
      lhu         $14,  2($3)
      lh          $15,  4($3)
      lh          $16,  6($3)

      #;; Calculate a "checksum" for easy comparison
      add         $17, $zero, $9
      add         $17, $17, $10
      add         $17, $17, $11
      add         $17, $17, $12
      add         $17, $17, $13
      add         $17, $17, $14
      add         $17, $17, $15
      add         $17, $17, $16

      #;; Stop processor
      addiu       $v0, $zero, 0xa
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
