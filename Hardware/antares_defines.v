//==================================================================================================
//  Filename      : antares_defines.v
//  Created On    : Mon Aug 31 19:32:04 2015
//  Last Modified : Mon Aug 31 21:45:57 2015
//  Revision      : 0.1
//  Author        : Angel Terrones
//  Company       : Universidad Simón Bolívar
//  Email         : aterrones@usb.ve
//
//  Description   : Opcodes and processor configuration
//==================================================================================================

//------------------------------------------------------------------------------
// Virtual/Physical Space
// No MMU, so VA = PA.
// First 0.5 GB: Kernel space
// Last  3.5 GB: User space
//
// WARNING: The address space is different to Standard MIPS
//------------------------------------------------------------------------------
`define ANTARES_SEG_0_SPACE_LOW    32'h0000_0000      // 256 MB: Internal Memory
`define ANTARES_SEG_0_SPACE_HIGH   32'h0FFF_FFFF
`define ANTARES_SEG_1_SPACE_LOW    32'h1000_0000      // 256 MB: I/O
`define ANTARES_SEG_1_SPACE_HIGH   32'h1FFF_FFFF
`define ANTARES_SEG_2_SPACE_LOW    32'h2000_0000      // 3.5 GB: External Memory
`define ANTARES_SEG_3_SPACE_HIGH   32'hFFFF_FFFF

//------------------------------------------------------------------------------
// Endianess
// 0 -> little-endian. 1 -> big-endian
//------------------------------------------------------------------------------
`define ANTARES_LITTLE_ENDIAN      0                   //
`define ANTARES_BIG_ENDIAN         1                   //

//------------------------------------------------------------------------------
// Exception Vector
//------------------------------------------------------------------------------
`define ANTARES_VECTOR_BASE_RESET      32'h0000_0010   // MIPS Standard is 0xBFC0_0000. Reset, soft-reset, NMI
`define ANTARES_VECTOR_BASE_BOOT       32'h0000_0000   // MIPS Standard is 0xBFC0_0200. Bootstrap (Status_BEV = 1)
`define ANTARES_VECTOR_BASE_NO_BOOT    32'h0000_0000   // MIPS Standard is 0x8000_0000. Normal (Status_BEV = 0)
`define ANTARES_VECTOR_OFFSET_GENERAL  32'h0000_0000   // MIPS Standard is 0x0000_0180. General exception, but TBL
`define ANTARES_VECTOR_OFFSET_SPECIAL  32'h0000_0008   // MIPS Standard is 0x0000_0200. Interrupts (Cause_IV = 1)

//------------------------------------------------------------------------------
/*
    Encoding for the MIPS Release 1 Architecture

    3 types of instructions:
        - R   : Register-Register
        - I   : Register-Immediate
        - J   : Jump

    Format:
    ------
        - R : Opcode(6) + Rs(5) + Rt(5) + Rd(5) + shamt(5) +  function(6)
        - I : Opcode(6) + Rs(5) + Rt(5) + Imm(16)
        - I : Opcode(6) + Imm(26)
*/
//------------------------------------------------------------------------------
// Opcode field for special instructions
//------------------------------------------------------------------------------
`define OP_TYPE_R               6'b00_0000          // Special
`define OP_TYPE_R2              6'b01_1100          // Special 2
`define OP_TYPE_REGIMM          6'b00_0001          // Branch/Trap
`define OP_TYPE_CP0             6'b01_0000          // Coprocessor 0
`define OP_TYPE_CP1             6'b01_0001          // Coprocessor 1
`define OP_TYPE_CP2             6'b01_0010          // Coprocessor 2
`define OP_TYPE_CP3             6'b01_0011          // Coprocessor 3

//------------------------------------------------------------------------------
// Instructions fields
//------------------------------------------------------------------------------
`define ANTARES_INSTR_OPCODE       31:26
`define ANTARES_INSTR_RS           25:21
`define ANTARES_INSTR_RT           20:16
`define ANTARES_INSTR_RD           15:11
`define ANTARES_INSTR_SHAMT        10:6
`define ANTARES_INSTR_FUNCT        5:0
`define ANTARES_INSTR_CP0_SEL      2:0
`define ANTARES_INSTR_IMM16        15:0
`define ANTARES_INSTR_IMM26        25:0

//------------------------------------------------------------------------------
// Opcode list
//------------------------------------------------------------------------------
`define OP_ADD                  `OP_TYPE_R
`define OP_ADDI                 6'b00_1000
`define OP_ADDIU                6'b00_1001
`define OP_ADDU                 `OP_TYPE_R
`define OP_AND                  `OP_TYPE_R
`define OP_ANDI                 6'b00_1100
`define OP_BEQ                  6'b00_0100
`define OP_BGEZ                 `OP_TYPE_REGIMM
`define OP_BGEZAL               `OP_TYPE_REGIMM
`define OP_BGTZ                 6'b00_0111
`define OP_BLEZ                 6'b00_0110
`define OP_BLTZ                 `OP_TYPE_REGIMM
`define OP_BLTZAL               `OP_TYPE_REGIMM
`define OP_BNE                  6'b00_0101
`define OP_BREAK                `OP_TYPE_R
`define OP_CLO                  `OP_TYPE_R2
`define OP_CLZ                  `OP_TYPE_R2
`define OP_DIV                  `OP_TYPE_R
`define OP_DIVU                 `OP_TYPE_R
`define OP_ERET                 `OP_TYPE_CP0
`define OP_J                    6'b00_0010
`define OP_JAL                  6'b00_0011
`define OP_JALR                 `OP_TYPE_R
`define OP_JR                   `OP_TYPE_R
`define OP_LB                   6'b10_0000
`define OP_LBU                  6'b10_0100
`define OP_LH                   6'b10_0001
`define OP_LHU                  6'b10_0101
`define OP_LL                   6'b11_0000
`define OP_LUI                  6'b00_1111
`define OP_LW                   6'b10_0011
`define OP_MADD                 `OP_TYPE_R2
`define OP_MADDU                `OP_TYPE_R2
`define OP_MFC0                 `OP_TYPE_CP0
`define OP_MFHI                 `OP_TYPE_R
`define OP_MFLO                 `OP_TYPE_R
`define OP_MOVN                 `OP_TYPE_R
`define OP_MOVZ                 `OP_TYPE_R
`define OP_MSUB                 `OP_TYPE_R2
`define OP_MSUBU                `OP_TYPE_R2
`define OP_MTC0                 `OP_TYPE_CP0
`define OP_MTHI                 `OP_TYPE_R
`define OP_MTLO                 `OP_TYPE_R
`define OP_MULT                 `OP_TYPE_R
`define OP_MULTU                `OP_TYPE_R
`define OP_NOR                  `OP_TYPE_R
`define OP_OR                   `OP_TYPE_R
`define OP_ORI                  6'b00_1101
`define OP_SB                   6'b10_1000
`define OP_SC                   6'b11_1000
`define OP_SH                   6'b10_1001
`define OP_SLL                  `OP_TYPE_R
`define OP_SLLV                 `OP_TYPE_R
`define OP_SLT                  `OP_TYPE_R
`define OP_SLTI                 6'b00_1010
`define OP_SLTIU                6'b00_1011
`define OP_SLTU                 `OP_TYPE_R
`define OP_SRA                  `OP_TYPE_R
`define OP_SRAV                 `OP_TYPE_R
`define OP_SRL                  `OP_TYPE_R
`define OP_SRLV                 `OP_TYPE_R
`define OP_SUB                  `OP_TYPE_R
`define OP_SUBU                 `OP_TYPE_R
`define OP_SW                   6'b10_1011
`define OP_SYSCALL              `OP_TYPE_R
`define OP_TEQ                  `OP_TYPE_R
`define OP_TEQI                 `OP_TYPE_REGIMM
`define OP_TGE                  `OP_TYPE_R
`define OP_TGEI                 `OP_TYPE_REGIMM
`define OP_TGEIU                `OP_TYPE_REGIMM
`define OP_TGEU                 `OP_TYPE_R
`define OP_TLT                  `OP_TYPE_R
`define OP_TLTI                 `OP_TYPE_REGIMM
`define OP_TLTIU                `OP_TYPE_REGIMM
`define OP_TLTU                 `OP_TYPE_R
`define OP_TNE                  `OP_TYPE_R
`define OP_TNEI                 `OP_TYPE_REGIMM
`define OP_XOR                  `OP_TYPE_R
`define OP_XORI                 6'b00_1110

//------------------------------------------------------------------------------
// Function field for R(2)-type instructions
//------------------------------------------------------------------------------
`define FUNCTION_OP_ADD         6'b10_0000
`define FUNCTION_OP_ADDU        6'b10_0001
`define FUNCTION_OP_AND         6'b10_0100
`define FUNCTION_OP_BREAK       6'b00_1101
`define FUNCTION_OP_CLO         6'b10_0001
`define FUNCTION_OP_CLZ         6'b10_0000
`define FUNCTION_OP_DIV         6'b01_1010
`define FUNCTION_OP_DIVU        6'b01_1011
`define FUNCTION_OP_JALR        6'b00_1001
`define FUNCTION_OP_JR          6'b00_1000
`define FUNCTION_OP_MADD        6'b00_0000
`define FUNCTION_OP_MADDU       6'b00_0001
`define FUNCTION_OP_MFHI        6'b01_0000
`define FUNCTION_OP_MFLO        6'b01_0010
`define FUNCTION_OP_MOVN        6'b00_1011
`define FUNCTION_OP_MOVZ        6'b00_1010
`define FUNCTION_OP_MSUB        6'b00_0100
`define FUNCTION_OP_MSUBU       6'b00_0101
`define FUNCTION_OP_MTHI        6'b01_0001
`define FUNCTION_OP_MTLO        6'b01_0011
`define FUNCTION_OP_MULT        6'b01_1000
`define FUNCTION_OP_MULTU       6'b01_1001
`define FUNCTION_OP_NOR         6'b10_0111
`define FUNCTION_OP_OR          6'b10_0101
`define FUNCTION_OP_SLL         6'b00_0000
`define FUNCTION_OP_SLLV        6'b00_0100
`define FUNCTION_OP_SLT         6'b10_1010
`define FUNCTION_OP_SLTU        6'b10_1011
`define FUNCTION_OP_SRA         6'b00_0011
`define FUNCTION_OP_SRAV        6'b00_0111
`define FUNCTION_OP_SRL         6'b00_0010
`define FUNCTION_OP_SRLV        6'b00_0110
`define FUNCTION_OP_SUB         6'b10_0010
`define FUNCTION_OP_SUBU        6'b10_0011
`define FUNCTION_OP_SYSCALL     6'b00_1100
`define FUNCTION_OP_TEQ         6'b11_0100
`define FUNCTION_OP_TGE         6'b11_0000
`define FUNCTION_OP_TGEU        6'b11_0001
`define FUNCTION_OP_TLT         6'b11_0010
`define FUNCTION_OP_TLTU        6'b11_0011
`define FUNCTION_OP_TNE         6'b11_0110
`define FUNCTION_OP_XOR         6'b10_0110

//------------------------------------------------------------------------------
// Branch >/< zero (and link), traps: Rt
//------------------------------------------------------------------------------
`define RT_OP_BGEZ              5'b00001
`define RT_OP_BGEZAL            5'b10001
`define RT_OP_BLTZ              5'b00000
`define RT_OP_BLTZAL            5'b10000
`define RT_OP_TEQI              5'b01100
`define RT_OP_TGEI              5'b01000
`define RT_OP_TGEIU             5'b01001
`define RT_OP_TLTI              5'b01010
`define RT_OP_TLTIU             5'b01011
`define RT_OP_TNEI              5'b01110

//------------------------------------------------------------------------------
// Rs field for Coprocessor instructions
//------------------------------------------------------------------------------
`define RS_OP_MFC               5'b00000
`define RS_OP_MTC               5'b00100

//------------------------------------------------------------------------------
// ERET
//------------------------------------------------------------------------------
`define RS_OP_ERET              5'b10000
`define FUNCTION_OP_ERET        6'b01_1000

//------------------------------------------------------------------------------
// ALU Operations
//------------------------------------------------------------------------------
`define ALU_OP_ADDU             5'd0
`define ALU_OP_ADD              5'd1
`define ALU_OP_SUB              5'd2
`define ALU_OP_SUBU             5'd3
`define ALU_OP_AND              5'd4
`define ALU_OP_MULS             5'd5
`define ALU_OP_MULU             5'd6
`define ALU_OP_NOR              5'd7
`define ALU_OP_OR               5'd8
`define ALU_OP_SLL              5'd9
`define ALU_OP_SRA              5'd10
`define ALU_OP_SRL              5'd11
`define ALU_OP_XOR              5'd12
`define ALU_OP_MFHI             5'd13
`define ALU_OP_MFLO             5'd14
`define ALU_OP_MTHI             5'd15
`define ALU_OP_MTLO             5'd16
`define ALU_OP_SLT              5'd17
`define ALU_OP_SLTU             5'd18
`define ALU_OP_DIV              5'd19
`define ALU_OP_DIVU             5'd20
`define ALU_OP_CLO              5'd21
`define ALU_OP_CLZ              5'd22
`define ALU_OP_MADD             5'd23
`define ALU_OP_MADDU            5'd24
`define ALU_OP_MSUB             5'd25
`define ALU_OP_MSUBU            5'd26
`define ALU_OP_A                5'd27
`define ALU_OP_B                5'd28

//------------------------------------------------------------------------------
/*
    Datapath controls.
    All signals are active High.
    ----------------------------------------------------------------------------
        Bit     Name                Description
    ----------------------------------------------------------------------------
        20 :    id_alu_operation        Operation to execute.
        19 :    .
        18 :    .
        17 :    .
        16 :    .
        -------------------------------
        15:     id_trap                 Trap instruction
        14:     id_trap_condition       Condition: ALU result = 0 (0), ALU result != 0 (1)
        -------------------------------
        13 :    id_gpr_we               Write enable (GPR)
        12 :    id_mem_to_gpr_select    Select data: ALU(0), MEM(1)
        -------------------------------
        11 :    id_alu_port_a_select    Select: Rs(0), shamt(1), 0x04(2), 0x10(3)
        10 :    .
        9  :    id_alu_port_b_select    Select: Rt(0), S/ZImm16(1), PCAdd4(2), CP0(3)
        8  :    .
        7  :    id_gpr_wa_select        Select register: Rd(0), Rt(1), 31(2)
        6  :    .
        -------------------------------
        5  :    id_jump                 Jump instruction
        4  :    id_branch               Branch instruction
        -------------------------------
        3  :    id_mem_write            Write to data memory
        2  :    id_mem_byte             Enable read/write one byte
        1  :    id_mem_halfword         Enable read/write 2 bytes (16 bits data)
        0  :    id_mem_data_sign_ext    Zero extend data (0) or Sign extend data (1)
    ----------------------------------------------------------------------------
*/
//------------------------------------------------------------------------------
`define DP_NONE        {`ALU_OP_AND,  16'b00_00_000000_00_0000}
`define DP_ADD         {`ALU_OP_ADD,  16'b00_10_000000_00_0000}
`define DP_ADDI        {`ALU_OP_ADD,  16'b00_10_000101_00_0000}
`define DP_ADDIU       {`ALU_OP_ADDU, 16'b00_10_000101_00_0000}
`define DP_ADDU        {`ALU_OP_ADDU, 16'b00_10_000000_00_0000}
`define DP_AND         {`ALU_OP_AND,  16'b00_10_000000_00_0000}
`define DP_ANDI        {`ALU_OP_AND,  16'b00_10_000101_00_0000}
`define DP_BEQ         {`ALU_OP_AND,  16'b00_00_000000_01_0000}
`define DP_BGEZ        {`ALU_OP_AND,  16'b00_00_000000_01_0000}
`define DP_BGEZAL      {`ALU_OP_ADD,  16'b00_10_101010_01_0000}
`define DP_BGTZ        {`ALU_OP_AND,  16'b00_00_000000_01_0000}
`define DP_BLEZ        {`ALU_OP_AND,  16'b00_00_000000_01_0000}
`define DP_BLTZ        {`ALU_OP_AND,  16'b00_00_000000_01_0000}
`define DP_BLTZAL      {`ALU_OP_ADD,  16'b00_10_101010_01_0000}
`define DP_BNE         {`ALU_OP_AND,  16'b00_00_000000_01_0000}
`define DP_BREAK       {`ALU_OP_AND,  16'b00_00_000000_00_0000}
`define DP_CLO         {`ALU_OP_CLO,  16'b00_10_000000_00_0000}
`define DP_CLZ         {`ALU_OP_CLZ,  16'b00_10_000000_00_0000}
`define DP_DIV         {`ALU_OP_DIV,  16'b00_00_000000_00_0000}
`define DP_DIVU        {`ALU_OP_DIVU, 16'b00_00_000000_00_0000}
`define DP_ERET        {`ALU_OP_AND,  16'b00_00_000000_00_0000}
`define DP_J           {`ALU_OP_AND,  16'b00_00_000000_10_0000}
`define DP_JAL         {`ALU_OP_ADD,  16'b00_10_101010_10_0000}
`define DP_JALR        {`ALU_OP_ADD,  16'b00_10_101010_01_0000}
`define DP_JR          {`ALU_OP_AND,  16'b00_00_000000_01_0000}
`define DP_LB          {`ALU_OP_ADDU, 16'b00_11_000101_00_0101}
`define DP_LBU         {`ALU_OP_ADDU, 16'b00_11_000101_00_0100}
`define DP_LH          {`ALU_OP_ADDU, 16'b00_11_000101_00_0011}
`define DP_LHU         {`ALU_OP_ADDU, 16'b00_11_000101_00_0010}
`define DP_LL          {`ALU_OP_ADDU, 16'b00_11_000101_00_0000}
`define DP_LUI         {`ALU_OP_SLL,  16'b00_10_110101_00_0000}
`define DP_LW          {`ALU_OP_ADDU, 16'b00_11_000101_00_0000}
`define DP_MADD        {`ALU_OP_MADD, 16'b00_00_000000_00_0000}
`define DP_MADDU       {`ALU_OP_MADDU,16'b00_00_000000_00_0000}
`define DP_MFC0        {`ALU_OP_B,    16'b00_10_001101_00_0000}
`define DP_MFHI        {`ALU_OP_MFHI, 16'b00_10_000000_00_0000}
`define DP_MFLO        {`ALU_OP_MFLO, 16'b00_10_000000_00_0000}
`define DP_MOVN        {`ALU_OP_A,    16'b00_00_000000_00_0000}
`define DP_MOVZ        {`ALU_OP_A,    16'b00_00_000000_00_0000}
`define DP_MSUB        {`ALU_OP_MSUB, 16'b00_00_000000_00_0000}
`define DP_MSUBU       {`ALU_OP_MSUBU,16'b00_00_000000_00_0000}
`define DP_MTC0        {`ALU_OP_AND,  16'b00_00_000000_00_0000}
`define DP_MTHI        {`ALU_OP_MTHI, 16'b00_00_000000_00_0000}
`define DP_MTLO        {`ALU_OP_MTLO, 16'b00_00_000000_00_0000}
`define DP_MULT        {`ALU_OP_MULS, 16'b00_00_000000_00_0000}
`define DP_MULTU       {`ALU_OP_MULU, 16'b00_00_000000_00_0000}
`define DP_NOR         {`ALU_OP_NOR,  16'b00_10_000000_00_0000}
`define DP_OR          {`ALU_OP_OR,   16'b00_10_000000_00_0000}
`define DP_ORI         {`ALU_OP_OR,   16'b00_10_000101_00_0000}
`define DP_SB          {`ALU_OP_ADDU, 16'b00_00_000100_00_1100}
`define DP_SC          {`ALU_OP_ADDU, 16'b00_11_000101_00_1000}
`define DP_SH          {`ALU_OP_ADDU, 16'b00_00_000100_00_1010}
`define DP_SLL         {`ALU_OP_SLL,  16'b00_10_010000_00_0000}
`define DP_SLLV        {`ALU_OP_SLL,  16'b00_10_000000_00_0000}
`define DP_SLT         {`ALU_OP_SLT,  16'b00_10_000000_00_0000}
`define DP_SLTI        {`ALU_OP_SLT,  16'b00_10_000101_00_0000}
`define DP_SLTIU       {`ALU_OP_SLTU, 16'b00_10_000101_00_0000}
`define DP_SLTU        {`ALU_OP_SLTU, 16'b00_10_000000_00_0000}
`define DP_SRA         {`ALU_OP_SRA,  16'b00_10_010000_00_0000}
`define DP_SRAV        {`ALU_OP_SRA,  16'b00_10_000000_00_0000}
`define DP_SRL         {`ALU_OP_SRL,  16'b00_10_010000_00_0000}
`define DP_SRLV        {`ALU_OP_SRL,  16'b00_10_000000_00_0000}
`define DP_SUB         {`ALU_OP_SUB,  16'b00_10_000000_00_0000}
`define DP_SUBU        {`ALU_OP_SUBU, 16'b00_10_000000_00_0000}
`define DP_SW          {`ALU_OP_ADDU, 16'b00_00_000100_00_1000}
`define DP_SYSCALL     {`ALU_OP_ADDU, 16'b00_00_000000_00_0000}
`define DP_TEQ         {`ALU_OP_SUBU, 16'b10_00_000000_00_0000}
`define DP_TEQI        {`ALU_OP_SUBU, 16'b10_00_000000_00_0000}
`define DP_TGE         {`ALU_OP_SLT,  16'b10_00_000000_00_0000}
`define DP_TGEI        {`ALU_OP_SLT,  16'b10_00_000000_00_0000}
`define DP_TGEIU       {`ALU_OP_SLTU, 16'b10_00_000000_00_0000}
`define DP_TGEU        {`ALU_OP_SLTU, 16'b10_00_000000_00_0000}
`define DP_TLT         {`ALU_OP_SLT,  16'b11_00_000000_00_0000}
`define DP_TLTI        {`ALU_OP_SLT,  16'b11_00_000000_00_0000}
`define DP_TLTIU       {`ALU_OP_SLTU, 16'b11_00_000000_00_0000}
`define DP_TLTU        {`ALU_OP_SLTU, 16'b11_00_000000_00_0000}
`define DP_TNE         {`ALU_OP_SUBU, 16'b11_00_000000_00_0000}
`define DP_TNEI        {`ALU_OP_SUBU, 16'b11_00_000000_00_0000}
`define DP_XOR         {`ALU_OP_XOR,  16'b00_10_000000_00_0000}
`define DP_XORI        {`ALU_OP_XOR,  16'b00_10_000101_00_0000}

//------------------------------------------------------------------------------
/*
    Exception.

    All signals are active High.

    ----------------------------------------------------------------------------
        Bit     Meaning
    ----------------------------------------------------------------------------
        2  :    Instruction can cause exception @ ID
        1  :    Instruction can cause exception @ EX
        0  :    Instruction can cause exception @ MEM
    ----------------------------------------------------------------------------
*/
//------------------------------------------------------------------------------
`define EXCEPTION_NONE  3'b000
`define EXCEPTION_ID    3'b100
`define EXCEPTION_EX    3'b010
`define EXCEPTION_MEM   3'b001
//
`define EXC_ADD         `EXCEPTION_EX
`define EXC_ADDI        `EXCEPTION_EX
`define EXC_ADDIU       `EXCEPTION_NONE
`define EXC_ADDU        `EXCEPTION_NONE
`define EXC_AND         `EXCEPTION_NONE
`define EXC_ANDI        `EXCEPTION_NONE
`define EXC_BEQ         `EXCEPTION_NONE
`define EXC_BGEZ        `EXCEPTION_NONE
`define EXC_BGEZAL      `EXCEPTION_NONE
`define EXC_BGTZ        `EXCEPTION_NONE
`define EXC_BLEZ        `EXCEPTION_NONE
`define EXC_BLTZ        `EXCEPTION_NONE
`define EXC_BLTZAL      `EXCEPTION_NONE
`define EXC_BNE         `EXCEPTION_NONE
`define EXC_BREAK       `EXCEPTION_ID
`define EXC_CLO         `EXCEPTION_NONE
`define EXC_CLZ         `EXCEPTION_NONE
`define EXC_DIV         `EXCEPTION_NONE
`define EXC_DIVU        `EXCEPTION_NONE
`define EXC_ERET        `EXCEPTION_ID
`define EXC_J           `EXCEPTION_NONE
`define EXC_JAL         `EXCEPTION_NONE
`define EXC_JALR        `EXCEPTION_NONE
`define EXC_JR          `EXCEPTION_NONE
`define EXC_LB          `EXCEPTION_MEM
`define EXC_LBU         `EXCEPTION_MEM
`define EXC_LH          `EXCEPTION_MEM
`define EXC_LHU         `EXCEPTION_MEM
`define EXC_LL          `EXCEPTION_MEM
`define EXC_LUI         `EXCEPTION_NONE
`define EXC_LW          `EXCEPTION_MEM
`define EXC_MADD        `EXCEPTION_NONE
`define EXC_MADDU       `EXCEPTION_NONE
`define EXC_MFC0        `EXCEPTION_ID
`define EXC_MFHI        `EXCEPTION_NONE
`define EXC_MFLO        `EXCEPTION_NONE
`define EXC_MOVN        `EXCEPTION_NONE
`define EXC_MOVZ        `EXCEPTION_NONE
`define EXC_MSUB        `EXCEPTION_NONE
`define EXC_MSUBU       `EXCEPTION_NONE
`define EXC_MTC0        `EXCEPTION_ID
`define EXC_MTHI        `EXCEPTION_NONE
`define EXC_MTLO        `EXCEPTION_NONE
`define EXC_MULT        `EXCEPTION_NONE
`define EXC_MULTU       `EXCEPTION_NONE
`define EXC_NOR         `EXCEPTION_NONE
`define EXC_OR          `EXCEPTION_NONE
`define EXC_ORI         `EXCEPTION_NONE
`define EXC_SB          `EXCEPTION_MEM
`define EXC_SC          `EXCEPTION_MEM
`define EXC_SH          `EXCEPTION_MEM
`define EXC_SLL         `EXCEPTION_NONE
`define EXC_SLLV        `EXCEPTION_NONE
`define EXC_SLT         `EXCEPTION_NONE
`define EXC_SLTI        `EXCEPTION_NONE
`define EXC_SLTIU       `EXCEPTION_NONE
`define EXC_SLTU        `EXCEPTION_NONE
`define EXC_SRA         `EXCEPTION_NONE
`define EXC_SRAV        `EXCEPTION_NONE
`define EXC_SRL         `EXCEPTION_NONE
`define EXC_SRLV        `EXCEPTION_NONE
`define EXC_SUB         `EXCEPTION_EX
`define EXC_SUBU        `EXCEPTION_EX
`define EXC_SW          `EXCEPTION_MEM
`define EXC_SYSCALL     `EXCEPTION_ID
`define EXC_TEQ         `EXCEPTION_MEM          // Requieres result from EX, so it triggers in the MEM stage
`define EXC_TEQI        `EXCEPTION_MEM          // Requieres result from EX, so it triggers in the MEM stage
`define EXC_TGE         `EXCEPTION_MEM          // Requieres result from EX, so it triggers in the MEM stage
`define EXC_TGEI        `EXCEPTION_MEM          // Requieres result from EX, so it triggers in the MEM stage
`define EXC_TGEIU       `EXCEPTION_MEM          // Requieres result from EX, so it triggers in the MEM stage
`define EXC_TGEU        `EXCEPTION_MEM          // Requieres result from EX, so it triggers in the MEM stage
`define EXC_TLT         `EXCEPTION_MEM          // Requieres result from EX, so it triggers in the MEM stage
`define EXC_TLTI        `EXCEPTION_MEM          // Requieres result from EX, so it triggers in the MEM stage
`define EXC_TLTIU       `EXCEPTION_MEM          // Requieres result from EX, so it triggers in the MEM stage
`define EXC_TLTU        `EXCEPTION_MEM          // Requieres result from EX, so it triggers in the MEM stage
`define EXC_TNE         `EXCEPTION_MEM          // Requieres result from EX, so it triggers in the MEM stage
`define EXC_TNEI        `EXCEPTION_MEM          // Requieres result from EX, so it triggers in the MEM stage
`define EXC_XOR         `EXCEPTION_NONE
`define EXC_XORI        `EXCEPTION_NONE

// EOF
