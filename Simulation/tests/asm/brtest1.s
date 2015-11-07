###############################################################################
# Filename      : musb-brtest2.s
# Created On    : 2015-04-12
# Revision      : 0.1
# Author        : Angel Terrones
# Company       : Universidad Simón Bolívar
# Email         : aterrones@usb.ve
# Description   : Branch test 2
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
l_0:
    j l_1
l_1:
    addiu       $10, $0, 0xff       # executes 2 times
    bne         $zero, $zero, l_3   # nope
l_2:
    beq         $zero, $zero, l_4
    addiu       $7, $zero, 0x347
    syscall
l_3:
    addiu       $7, $zero, 0x1337
l_4:
    addiu       $7, $zero, 0xd00d
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
