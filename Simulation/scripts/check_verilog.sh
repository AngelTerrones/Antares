#!/bin/bash
#-------------------------------------------------------------------------------
# Copyright (C) 2015 Angel Terrones <angelterrones@gmail.com>
#-------------------------------------------------------------------------------
#
# File Name: check_verilog
#
# Author:
#             - Angel Terrones <angelterrones@gmail.com>
# Description:
#       Check syntax.
#       Arguments:
#           1.- Input:  File list (synth)
#           2.- Input:  File list (testbenchs)
#           3.- Output: Log file
#-------------------------------------------------------------------------------

###############################################################################
#                            Parameter Check                                  #
###############################################################################
EXPECTED_ARGS=1
if [ $# -ne $EXPECTED_ARGS ]; then
    echo
    echo -e "ERROR\t: wrong number of arguments"
    echo -e "USAGE\t: check_verilog <File list (synth)>"
    echo
    exit 1
fi

###############################################################################
#                       Check if filelist exist                               #
###############################################################################
if [ ! -e $1 ]; then
    echo
    echo -e "ERROR:\tFile list (synth) doesn't exist: $1"
    echo
    exit 1
fi
if [ ! -e $2 ]; then
    echo
    echo -e "ERROR:\tFile list (testbenchs) doesn't exist: $2"
    echo
    exit 1
fi

if !(iverilog -c$1 -t null) then
    echo
    echo -e "ERROR:\tCheck error."
    echo
    exit 1
fi

echo -e "--------------------------------------------------------------------------"
echo -e "INFO:\tCheck syntax: OK."
echo -e "--------------------------------------------------------------------------"
