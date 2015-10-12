###############################################################################
# Filename      : musb-brtest0.s
# Created On    : 2015-04-12
# Revision      : 0.1
# Author        : Angel Terrones
# Company       : Universidad Simón Bolívar
# Email         : aterrones@usb.ve
# Description   : Branch test 0
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
    addiu       $v0,  $zero, 0xa
    add         $1, $0, $0
l_0:
    addiu       $5,   $zero, 1
    j           l_1
    addiu       $10,  $zero, 0xf00    # BDS
    ori         $1,   $1,    0x01
    ori         $1,   $1,    0x02
    addiu       $5,   $zero, 100
    syscall
l_1:
    bne         $zero, $zero, l_3
    ori         $1,    $1,    0x04
    ori         $1,    $1,    0x08
    addiu       $6,    $zero, 0x1337
l_2:
    beq         $zero, $zero, l_4
    ori         $1,    $1,    0x10    # BDS
    ori         $1,    $1,    0x20
    # Should not reach here
    addiu       $7,   $zero,  0x347
    syscall
l_3:
    # Should not reach here
    addiu       $8,   $zero,  0x347
    syscall
l_4:
    addiu       $7,   $zero, 0xd00d
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
