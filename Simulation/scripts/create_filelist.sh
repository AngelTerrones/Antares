#!/bin/bash
#-------------------------------------------------------------------------------
# Copyright (C) 2014 Angel Terrones <angelterrones@gmail.com>
#-------------------------------------------------------------------------------
#
# File Name: create_filelist
#
# Author:
#             - Angel Terrones <angelterrones@gmail.com>
#
#-------------------------------------------------------------------------------

# Set the folders

CURRENT_FOLDER="$(pwd)"
PROJECT_ROOT="${CURRENT_FOLDER%/Simulation*}"

RTL_FOLDER=$PROJECT_ROOT/Hardware
RUN_FOLDER=$PROJECT_ROOT/Simulation/run
TESTBENCH_FOLDER=$PROJECT_ROOT/Simulation/bench

# Set Filelist variable
# Create the file inside $RUN_FOLDER
mkdir -p $RUN_FOLDER/build
FILELIST_ICARUS=$RUN_FOLDER/build/filelist.prj

# remove old files
rm -f $RUN_FOLDER/build/*

#create the new filelist of rtl
touch $FILELIST_ICARUS

find $RTL_FOLDER -name "*.v" >> $FILELIST_ICARUS
find $TESTBENCH_FOLDER -name "*.v" >> $FILELIST_ICARUS

#-------------------------------------------------------------------------------
# Xilinx libraries.
# echo +libdir+/opt/Xilinx/14.7/ISE_DS/ISE/verilog/src/unisims >> $FILELIST_ICARUS
#-------------------------------------------------------------------------------

for folder in $(find $RTL_FOLDER -type d)
do
    echo "+incdir+"$folder >> $FILELIST_ICARUS
done
