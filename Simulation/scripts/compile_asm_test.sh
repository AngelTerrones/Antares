#!/bin/bash
#-------------------------------------------------------------------------------
# Copyright (C) 2015 Angel Terrones <angelterrones@gmail.com>
#-------------------------------------------------------------------------------
#
# File Name: compile_asm_test.sh
#
# Author:
#             - Angel Terrones <angelterrones@gmail.com>
# Description:
#       Compile input test
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# Folders
#-------------------------------------------------------------------------------
TEMPLATES_FOLDER=../../Software/templates;
BUILD_FOLDER=../out/tmp;
UTIL_FOLDER=$(cd ../../Software/utils; pwd)

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
EXPECTED_ARGS=3
if [ $# -ne $EXPECTED_ARGS ]; then
    echo
    echo -e "ERROR      : wrong number of arguments"
    echo -e "USAGE      : compile_test <test name> <mem size> <data size>"
    echo -e "Example    : compile_test musb-addiu 2048 1024"
    echo
    exit 1
fi

#-------------------------------------------------------------------------------
# Check if file exist
#-------------------------------------------------------------------------------
asm=../tests/asm/$1.s;

if [ ! -e ${asm} ]; then
    echo -e "ERROR:\tAssembler file doesn't exist: ${asm}"
    echo
    exit 1
fi

#-------------------------------------------------------------------------------
# Copy makefile, linker script & assembler test
#-------------------------------------------------------------------------------
rm -rf ${BUILD_FOLDER}/*
mkdir -p ${BUILD_FOLDER}
mkdir -p ${BUILD_FOLDER}/src
cp ${TEMPLATES_FOLDER}/makefile_template ${BUILD_FOLDER}/makefile
cp ${TEMPLATES_FOLDER}/linker_template ${BUILD_FOLDER}/linker.ls
cp ${asm} ${BUILD_FOLDER}/src/$1.s


#-------------------------------------------------------------------------------
# Regenerate linker
#-------------------------------------------------------------------------------
MEM_SIZE=$(printf '0x%08x' $2);
TEXT_BEGIN=$(printf '0x%08x' 0);
TEXT_END=$(printf '0x%08x' $(($2-$3-1)));
DATA_BEGIN=$(printf '0x%08x' $(($2-$3)));
DATA_END=$(printf '0x%08x' $(($2-1)));
STACK_BEGIN=$(printf '0x%08x' $2);

sed -i "s/%size%/$2 ($MEM_SIZE)/g" ${BUILD_FOLDER}/linker.ls
sed -i "s/%textsegbegin%/$TEXT_BEGIN/g" ${BUILD_FOLDER}/linker.ls
sed -i "s/%textsegend%/$TEXT_END/g" ${BUILD_FOLDER}/linker.ls
sed -i "s/%datasegbegin%/$DATA_BEGIN/g" ${BUILD_FOLDER}/linker.ls
sed -i "s/%datasegend%/$DATA_END/g" ${BUILD_FOLDER}/linker.ls
sed -i "s/%stackBegin%/$STACK_BEGIN/g" ${BUILD_FOLDER}/linker.ls

sed -i "s/%bootcode%//g" ${BUILD_FOLDER}/linker.ls
sed -i "s/%exceptioncode%//g" ${BUILD_FOLDER}/linker.ls

#-------------------------------------------------------------------------------
# Regenerate makefile
#-------------------------------------------------------------------------------
PAD_SIZE=$(($2/4))
DATA_BEGIN=$(($2-$3))

# search & replace variables
sed -i "s/%prefix%/$MIPS_PREFIX/g" ${BUILD_FOLDER}/makefile
sed -i "s@%bin%@$MIPS_BIN@g" ${BUILD_FOLDER}/makefile
sed -i "s@%base%@$MIPS_BASE@g" ${BUILD_FOLDER}/makefile
sed -i "s@%util%@$UTIL_FOLDER@g" ${BUILD_FOLDER}/makefile
sed -i "s/%linker%/linker.ls/g" ${BUILD_FOLDER}/makefile
sed -i "s/%optlevel%/3/g" ${BUILD_FOLDER}/makefile

sed -i "s@%project%@$1@g" ${BUILD_FOLDER}/makefile
sed -i "s/%datasegbegin%/${DATA_BEGIN}/g" ${BUILD_FOLDER}/makefile
sed -i "s/%padsize%/${PAD_SIZE}/g" ${BUILD_FOLDER}/makefile


#-------------------------------------------------------------------------------
# Build utils if necessary:
# bin2mem & bin2hex
#-------------------------------------------------------------------------------
make -s -C ${UTIL_FOLDER}

#-------------------------------------------------------------------------------
# Build assembler test
#-------------------------------------------------------------------------------
echo -e "--------------------------------------------------------------------------"
echo -e "INFO:\tCompiling Assembler Test: $(readlink -f ${asm})"
if !(make -s -C ${BUILD_FOLDER}) then
    echo -e ""
    echo -e "ERROR:\tCompile error: ASM = $(readlink -f ${asm})"
    echo -e ""
    exit 1
fi
echo -e "INFO:\tAssembler Test compilation: DONE."
echo -e "--------------------------------------------------------------------------"

#-------------------------------------------------------------------------------
# Copy test to out folder
#-------------------------------------------------------------------------------
mv ${BUILD_FOLDER}/bin/$1.mem ${BUILD_FOLDER}/../mem.hex
