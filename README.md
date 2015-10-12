![logo](Documentation/src/images/png/logo.png)

Implementation of the MIPS32 release 1 processor.

Based on the [XUM project](https://github.com/grantea/mips32r1_xum) created by Grant Ayers
for the eXtensible Utah Multicore (XUM) project at the University of Utah.

## Processor Details

-  Single-issue in-order 6-stage pipeline with full forwarding and hazard detection.
-  Harvard architecture, with separate instruction and data ports.
-  A subset of the MIPS32 instruction set. Includes: hardware multiplication, hardware division, MAC/MAS, load linked / store conditional.
-  No MMU.
-  No Cache.
-  No FPU. Only software-base floating point support (toolchain).
-  Multi-cycle Hardware divider (Disabled by default).
-  Hardware multiplier (5-stages pipeline, disabled by default).
-  Hardware is Little-Endian. No support for reverse-endian mode.
-  Coprocessor 0 allows ISA-compliant interrupts, exceptions, and user/kernel modes.
-  No address space verification for the instruction port: code can be at any address.
-  Documentation in-source.
-  Vendor-independent code.

The project includes only the standalone MIPS32 processor.

## Getting Started

This repository provides all you need to simulate and synthesize the processor:

-   Standalone processor.
-   Internal memory using BRAM (Vendor-independent code).
-   Scripts to simulate the processor.

## Software Details

-  Software toolchain based on Mentor Graphics Sourcery CodeBench Lite for MIPS ELF (easy way).
-  Demos written in assembly.

## Directory Layout

```
Antares
├── Documentation/
│   ├── src/                 : Source files (texinfo).
│   └── makefile
├── Hardware/
│   ├── antares_add.v
│   ├── antares_alu.v
│   ├── antares_branch_unit.v
│   ├── antares_cloz.v
│   ├── antares_control_unit.v
│   ├── antares_core.v
│   ├── antares_cpzero.v
│   ├── antares_defines.v
│   ├── antares_divider.v
│   ├── antares_exmem_register.v
│   ├── antares_hazard_unit.v
│   ├── antares_idex_register.v
│   ├── antares_ifid_register.v
│   ├── antares_load_store_unit.v
│   ├── antares_memwb_register.v
│   ├── antares_multiplier.v
│   ├── antares_mux_2_1.v
│   ├── antares_mux_4_1.v
│   ├── antares_pc_register.v
│   ├── antares_reg_file.v
│   └── antares_shifter.v
├── Simulation/
│   ├── bench/               : Testbenchs for the core & SoC.
│   ├── run/                 : Run scripts (makefile).
│   ├── scripts/             : Scripts needed for the simulation makefile.
│   ├── tests/               : Test folders: assembler & C
│   └── README.md
├── Software/
│   ├── templates/           : Templates for project creation and simulation.
│   ├── toolchain/           : Toolchain instructions.
│   └── utils/               : Utilities for creating the binary image and HEX file for simulation.
│   └── README.md
├── MITlicense.md
└── README.md
```

## License

Copyright (c) 2015 Angel Terrones (<angelterrones@gmail.com>).

Release under the [MIT License](MITlicense.md).

[1]: http://iverilog.icarus.com
