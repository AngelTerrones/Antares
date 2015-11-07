# Simulation

Software needed to simulate the Antares processor.

## Directory Layout

```
Simulation
├── bench/
│   └── verilog/
│       ├── utils/           : Core monitors.
│       └── tb_core.v        : Testbench: Interconnects the core and the BRAM module.
├── run/                     :
│   └── makefile             : Makefile
├── scripts/                 :
│   ├── check_verilog.sh*    : Check verilog syntax (only hardware/testbenchs).
│   ├── compile_asm_test.sh* : Compile asm test.
│   ├── compile_c_test.sh*   : Compile C project (test).
│   ├── create_filelist.sh*  : Create list of verilog input files for testbench compilation.
│   ├── help_screen.sh*      : Print help screen for makefile.
│   └── rtlsim.sh*           : Compiles and executes the RTL simulation.
├── tests/
│   ├── asm/                 : Assembler demos.
│   └── c/                   : C demos.
└── README.md
```

## Run the simulation

To simulate the processor, follow the makefile instructions:

- Change directory to ```<project directory>\Simulation\run```.
- Execute ```make``` to get help screen. The output of ```make``` with no targets:

        ```
        Makefile:  HELP SCREEN

        USAGE:
            make TARGET VARIABLE


        TARGETS:
            help
                This help.

            check
                Check Verilog files found in Hardware and Simulation/testbench folders;

            list_asm_tests
                List all assembler files inside the Simulation/tests/asm/ folder;

            list_c_tests
                List all C projects inside the Simulation/tests/c/ folder;

            rtlsim
                Simulates a single ASM test, and places all outputs (waveforms, regdump, logs)
                in Simulation/out folder

            rtlsim-c
                Simulates a single C test, and places all outputs (waveforms, regdump, logs)
                in Simulation/out folder

            rtlsim-all
                Simulates all ASM tests, and places all outputs (waveforms, regdump, logs)
                in Simulation/out folder

            clean
                Clean temporary files inside the Simulation folder.

            distclean
                Clean all temporary files.

        VARIABLES:
            TB=Verilog testbench.

            TEST=ASM test.

            MEM_SIZE=Memory size.

            DSEG_SIZE=Size of Data Segment.

            TIMEOUT=Simulation timeout.

            DUMPVCD=Generate waveform file.

        EXAMPLES:
                make
                make help
                make check
                make list_asm_tests
                make list_c_tests
                make rtlsim TB=tb_core TEST=<asm-test> MEM_SIZE=4096 DSEG_SIZE=1024 TIMEOUT=100000 DUMPVCD=0
                make rtlsim-c TB=tb_core TEST=<c-test> MEM_SIZE=4096 DSEG_SIZE=1024 TIMEOUT=100000 DUMPVCD=0
                make rtlsim-all TB=tb_core MEM_SIZE=4096 DSEG_SIZE=1024 TIMEOUT=100000 DUMPVCD=0
                make clean
                make distclean

        (END)
        ```

- Execute, from the __run__ folder: ```make rtlsim TB=tb_core TEST=<asm-test> MEM_SIZE=4096 DSEG_SIZE=1024 TIMEOUT=100000 DUMPVCD=0```.
  For the __TB__ and __TEST__ variables, __do not include the file extension__.
