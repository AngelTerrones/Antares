###############################################################################
# Filename      : add.s
# Created On    : 2015-10-11
# Revision      : 0.1
# Author        : Angel Terrones
# Company       : Universidad Simón Bolívar
# Email         : aterrones@usb.ve
# Description   : add test
###############################################################################

    .text
    .balign 4

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
    addiu       $1,  $0, 30
    addiu       $2,  $0, 15
    addiu       $3,  $0, -20
    addiu       $4,  $0, -10
    addiu       $5,  $2, 5
    addiu       $6,  $3, -12
    addiu       $7,  $4, -1000
    addiu       $8,  $5, 1234
    addiu       $9,  $6, 876
    addiu       $10, $7, -456
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
