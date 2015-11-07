#!/bin/bash
#-------------------------------------------------------------------------------
# Copyright (C) 2015 Angel Terrones <angelterrones@gmail.com>
#-------------------------------------------------------------------------------
#
# File Name: compile_c_test.sh
#
# Author:
#             - Angel Terrones <angelterrones@gmail.com>
# Description:
#       Compile input test
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# Folders
#-------------------------------------------------------------------------------
CURRENT_FOLDER="$(pwd)"
PROJECT_ROOT="${CURRENT_FOLDER%/Simulation*}"
SIM_FOLDER=$PROJECT_ROOT/Simulation/run/out
UTIL_FOLDER=$PROJECT_ROOT/Software/utils
C_PROJECT_FOLDER=$PROJECT_ROOT/Simulation/tests/c

#-------------------------------------------------------------------------------
# MIPS compiler
# Point this to your compiler
#-------------------------------------------------------------------------------
MIPS_PREFIX=mips-sde-elf-;
MIPS_BIN=/opt/mgc/embedded/codebench/bin;
MIPS_BASE=/opt/mgc/embedded/codebench;

#-------------------------------------------------------------------------------
# Parameter Check
#-------------------------------------------------------------------------------
EXPECTED_ARGS=1
if [ $# -ne $EXPECTED_ARGS ]; then
    echo
    echo -e "ERROR      : wrong number of arguments"
    echo -e "USAGE      : compile_c_test <test name>"
    echo -e "Example    : compile_c_test factorial"
    echo
    exit 1
fi

#-------------------------------------------------------------------------------
# Check if file exist
#-------------------------------------------------------------------------------
c_project=$C_PROJECT_FOLDE/$1;

if [ ! -e ${asm} ]; then
    echo -e "ERROR:\tC project doesn't exist: ${c_project}"
    echo
    exit 1
fi

#-------------------------------------------------------------------------------
# Build utils if necessary:
# bin2mem & bin2hex
#-------------------------------------------------------------------------------
make -s -C ${UTIL_FOLDER}

#-------------------------------------------------------------------------------
# Build C test
#-------------------------------------------------------------------------------
echo -e "--------------------------------------------------------------------------"
echo -e "INFO:\tCompiling C Test: $(readlink -f ${c_project})"
if !(make -s -B -C ${c_project}) then
    echo -e ""
    echo -e "ERROR:\tCompile error: C = $(readlink -f ${c_project})"
    echo -e ""
    exit 1
fi
echo -e "INFO:\tC Test compilation: DONE."
echo -e "--------------------------------------------------------------------------"

#-------------------------------------------------------------------------------
# Copy test to out folder
#-------------------------------------------------------------------------------
rm -rf ${SIM_FOLDER}
mkdir -p ${SIM_FOLDER}
mv ${c_project}/bin/$1.mem ${SIM_FOLDER}/mem.hex
make clean -s -C ${c_project}
