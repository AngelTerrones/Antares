###############################################################################
# Makefile to run verilog simulations, using Icarus Verilog
# Angel Terrones <angelterrones@gmail.com>
###############################################################################
SHELL := bash

#-------------------------------------------------------------------------------
# variables
# must match the name on create_filelist script
#-------------------------------------------------------------------------------
.FILE_LIST     = build/filelist.prj
.MEM_FILE_NAME = ../out/pmem.mem

#-------------------------------------------------------------------------------
# Test folders
#-------------------------------------------------------------------------------
.ASM_TESTS_FOLDER=../tests/asm
.ASM_TESTS=$(shell ls -1 $(.ASM_TESTS_FOLDER))

.C_TESTS_FOLDER=../tests/c
.C_TESTS=$(shell ls -1 $(.C_TESTS_FOLDER))


#-------------------------------------------------------------------------------
# targets
#-------------------------------------------------------------------------------
.PHONY: default clean list_asm_tests list_c_tests

#-------------------------------------------------------------------------------
help:
	@../scripts/help_screen.sh

#-------------------------------------------------------------------------------
check:	.Filelist
	@../scripts/check_verilog.sh $(.FILE_LIST)

#-------------------------------------------------------------------------------
.check-%:
	@if [ "${${*}}" == "" ]; then \
		echo -e ""; \
		echo -e "Makefile: ERROR: Environment variable $* not set"; \
		echo -e ""; \
		exit 1; \
    fi

#-------------------------------------------------------------------------------
rtlsim: .check-TB .check-TEST .check-MEM_SIZE .check-DSEG_SIZE .check-TIMEOUT .check-DUMPVCD check
	@../scripts/compile_asm_test.sh $(TEST) $(MEM_SIZE) $(DSEG_SIZE)
	@../scripts/rtlsim.sh $(TB) $(TEST) $(.FILE_LIST) $(TIMEOUT) $(DUMPVCD)

#-------------------------------------------------------------------------------
rtlsim-all: .check-TB .check-MEM_SIZE .check-DSEG_SIZE .check-TIMEOUT .check-DUMPVCD check
	@for test in $(basename $(.ASM_TESTS)); do \
		../scripts/compile_asm_test.sh $$test $(MEM_SIZE) $(DSEG_SIZE); \
		../scripts/rtlsim.sh $(TB) $$test $(.FILE_LIST) $(TIMEOUT) $(DUMPVCD); \
	done

#-------------------------------------------------------------------------------
rtlsim-c: .check-TB .check-TEST .check-MEM_SIZE .check-DSEG_SIZE .check-TIMEOUT .check-DUMPVCD check
	@../scripts/compile_c_test.sh $(TEST)
	@../scripts/rtlsim.sh $(TB) $(TEST) $(.FILE_LIST) $(TIMEOUT) $(DUMPVCD)

#-------------------------------------------------------------------------------
list_asm_tests:
	@echo -e "--------------------------------------------------------------------------"
	@echo -e "Available tests under$(.ASM_TESTS_FOLDER):"
	@echo -e ""
	@for test in $(.ASM_TESTS); do echo -e $$test; done
	@echo -e "--------------------------------------------------------------------------"

#-------------------------------------------------------------------------------
list_c_tests:
	@echo -e "--------------------------------------------------------------------------"
	@echo -e "Available tests under$(.C_TESTS_FOLDER):"
	@echo -e ""
	@for test in $(.C_TESTS); do echo -e $$test; done
	@echo -e "--------------------------------------------------------------------------"

#-------------------------------------------------------------------------------
view: .check-VCD
	@gtkwave $(VCD) &

#-------------------------------------------------------------------------------
clean:
	@echo -e ""
	rm -rf ../out
	rm -rf build
	rm -f *.prj
	rm -f *.log
	rm -f *.vvp
	rm -f *.vcd
	rm -f *.out
	@echo -e ""

#-------------------------------------------------------------------------------
distclean: clean
	@make -s -C ../../Software/utils/ clean

#-------------------------------------------------------------------------------
# Dependencies
#-------------------------------------------------------------------------------
.Filelist:
	@../scripts/create_filelist.sh
