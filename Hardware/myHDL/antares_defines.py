#!/usr/bin/env python
"""
Filename      : antares_defines.py
Revision      : 0.1
Author        : Angel Terrones
Email         : aterrones@usb.ve

Description   : Opcodes and processor configuration
"""

from myhdl import concat
from myhdl import intbv

# ------------------------------------------------------------------------------
# Virtual/Physical Space
# No MMU, so VA =  PA
# First 0.5 GB: Kernel Space.
# Last  3.5 GB: User Space
# Address space is different to Standard MIPS
# ------------------------------------------------------------------------------
ANTARES_SEG0_SPACE_LOW = intbv(0x00000000)[32:]   # 256 MB: Internal Memory
ANTARES_SEG0_SPACE_HIGH = intbv(0x0FFFFFFF)[32:]
ANTARES_SEG1_SPACE_LOW = intbv(0x10000000)[32:]   # 256 MB: I/O
ANTARES_SEG1_SPACE_HIGH = intbv(0x1FFFFFFF)[32:]
ANTARES_SEG2_SPACE_LOW = intbv(0x20000000)[32:]   # 3.5 GB: External Memory
ANTARES_SEG2_SPACE_HIGH = intbv(0xFFFFFFFF)[32:]

# ------------------------------------------------------------------------------
# Endianess
# 0 -> little-endian. 1 -> big-endian.
# ------------------------------------------------------------------------------
ANTARES_LITTLE_ENDIAN = intbv(0)[32:]
ANTARES_BIG_ENDIAN = intbv(1)[32:]

# ------------------------------------------------------------------------------
# Exception Vector
# ------------------------------------------------------------------------------
ANTARES_VECTOR_BASE_RESET = intbv(0x00000010)[32:]      # MIPS Standard is 0xBFC0_0000. Reset, soft-reset, NMI
ANTARES_VECTOR_BASE_BOOT = intbv(0x00000000)[32:]       # MIPS Standard is 0xBFC0_0200. Bootstrap (Status_BEV = 1)
ANTARES_VECTOR_BASE_NO_BOOT = intbv(0x00000000)[32:]    # MIPS Standard is 0x8000_0000. Normal (Status_BEV = 0)
ANTARES_VECTOR_OFFSET_GENERAL = intbv(0x00000000)[32:]  # MIPS Standard is 0x0000_0180. General exception, but TBL0
ANTARES_VECTOR_OFFSET_SPECIAL = intbv(0x00000008)[32:]  # MIPS Standard is 0x0000_0200. Interrupts (Cause_IV = 1) 8

# ------------------------------------------------------------------------------
#    Encoding for the MIPS Release 1 Architecture
#
#    3 types of instructions:
#        - R   : Register-Register
#        - I   : Register-Immediate
#        - J   : Jump
#
#    Format:
#    ------
#        - R : Opcode(6) + Rs(5) + Rt(5) + Rd(5) + shamt(5) +  function(6)
#        - I : Opcode(6) + Rs(5) + Rt(5) + Imm(16)
#        - I : Opcode(6) + Imm(26)
# ------------------------------------------------------------------------------
OP_TYPE_R = intbv(0b000000)[6:]  # Special
OP_TYPE_R2 = intbv(0b011100)[6:]  # Special 2
OP_TYPE_REGIMM = intbv(0b000001)[6:]  # Branch/Trap
OP_TYPE_CP0 = intbv(0b010000)[6:]  # Coprocessor 0
OP_TYPE_CP1 = intbv(0b010001)[6:]  # Coprocessor 1
OP_TYPE_CP2 = intbv(0b010010)[6:]  # Coprocessor 2
OP_TYPE_CP3 = intbv(0b010011)[6:]  # Coprocessor 3

# ------------------------------------------------------------------------------
# Instructions fields
# ------------------------------------------------------------------------------
ANTARES_INSTR_OPCODE = slice(31, 26)
ANTARES_INSTR_RS = slice(25, 21)
ANTARES_INSTR_RT = slice(20, 16)
ANTARES_INSTR_RD = slice(15, 11)
ANTARES_INSTR_SHAMT = slice(10, 6)
ANTARES_INSTR_FUNCT = slice(5, 0)
ANTARES_INSTR_CP0_SEL = slice(2, 0)
ANTARES_INSTR_IMM16 = slice(15, 0)
ANTARES_INSTR_IMM26 = slice(25, 0)

# ------------------------------------------------------------------------------
# Opcode list
# ------------------------------------------------------------------------------
OP_ADD = OP_TYPE_R
OP_ADDI = intbv(0b001000)[6:]
OP_ADDIU = intbv(0b001001)[6:]
OP_ADDU = OP_TYPE_R
OP_AND = OP_TYPE_R
OP_ANDI = intbv(0b001100)[6:]
OP_BEQ = intbv(0b000100)[6:]
OP_BGEZ = OP_TYPE_REGIMM
OP_BGEZAL = OP_TYPE_REGIMM
OP_BGTZ = intbv(0b000111)[6:]
OP_BLEZ = intbv(0b000110)[6:]
OP_BLTZ = OP_TYPE_REGIMM
OP_BLTZAL = OP_TYPE_REGIMM
OP_BNE = intbv(0b000101)[6:]
OP_BREAK = OP_TYPE_R
OP_CLO = OP_TYPE_R2
OP_CLZ = OP_TYPE_R2
OP_DIV = OP_TYPE_R
OP_DIVU = OP_TYPE_R
OP_ERET = OP_TYPE_CP0
OP_J = intbv(0b000010)[6:]
OP_JAL = intbv(0b000011)[6:]
OP_JALR = OP_TYPE_R
OP_JR = OP_TYPE_R
OP_LB = intbv(0b100000)[6:]
OP_LBU = intbv(0b100100)[6:]
OP_LH = intbv(0b100001)[6:]
OP_LHU = intbv(0b100101)[6:]
OP_LL = intbv(0b110000)[6:]
OP_LUI = intbv(0b001111)[6:]
OP_LW = intbv(0b100011)[6:]
OP_MADD = OP_TYPE_R2
OP_MADDU = OP_TYPE_R2
OP_MFC0 = OP_TYPE_CP0
OP_MFHI = OP_TYPE_R
OP_MFLO = OP_TYPE_R
OP_MOVN = OP_TYPE_R
OP_MOVZ = OP_TYPE_R
OP_MSUB = OP_TYPE_R2
OP_MSUBU = OP_TYPE_R2
OP_MTC0 = OP_TYPE_CP0
OP_MTHI = OP_TYPE_R
OP_MTLO = OP_TYPE_R
OP_MULT = OP_TYPE_R
OP_MULTU = OP_TYPE_R
OP_NOR = OP_TYPE_R
OP_OR = OP_TYPE_R
OP_ORI = intbv(0b001101)[6:]
OP_SB = intbv(0b101000)[6:]
OP_SC = intbv(0b111000)[6:]
OP_SH = intbv(0b101001)[6:]
OP_SLL = OP_TYPE_R
OP_SLLV = OP_TYPE_R
OP_SLT = OP_TYPE_R
OP_SLTI = intbv(0b001010)[6:]
OP_SLTIU = intbv(0b001011)[6:]
OP_SLTU = OP_TYPE_R
OP_SRA = OP_TYPE_R
OP_SRAV = OP_TYPE_R
OP_SRL = OP_TYPE_R
OP_SRLV = OP_TYPE_R
OP_SUB = OP_TYPE_R
OP_SUBU = OP_TYPE_R
OP_SW = intbv(0b101011)[6:]
OP_SYSCALL = OP_TYPE_R
OP_TEQ = OP_TYPE_R
OP_TEQI = OP_TYPE_REGIMM
OP_TGE = OP_TYPE_R
OP_TGEI = OP_TYPE_REGIMM
OP_TGEIU = OP_TYPE_REGIMM
OP_TGEU = OP_TYPE_R
OP_TLT = OP_TYPE_R
OP_TLTI = OP_TYPE_REGIMM
OP_TLTIU = OP_TYPE_REGIMM
OP_TLTU = OP_TYPE_R
OP_TNE = OP_TYPE_R
OP_TNEI = OP_TYPE_REGIMM
OP_XOR = OP_TYPE_R
OP_XORI = intbv(0b001110)[6:]

# ------------------------------------------------------------------------------
# Function field for R(2)-type instructions
# ------------------------------------------------------------------------------
FUNCTION_OP_ADD = intbv(0b100000)[6:]
FUNCTION_OP_ADDU = intbv(0b100001)[6:]
FUNCTION_OP_AND = intbv(0b100100)[6:]
FUNCTION_OP_BREAK = intbv(0b001101)[6:]
FUNCTION_OP_CLO = intbv(0b100001)[6:]
FUNCTION_OP_CLZ = intbv(0b100000)[6:]
FUNCTION_OP_DIV = intbv(0b011010)[6:]
FUNCTION_OP_DIVU = intbv(0b011011)[6:]
FUNCTION_OP_JALR = intbv(0b001001)[6:]
FUNCTION_OP_JR = intbv(0b001000)[6:]
FUNCTION_OP_MADD = intbv(0b000000)[6:]
FUNCTION_OP_MADDU = intbv(0b000001)[6:]
FUNCTION_OP_MFHI = intbv(0b010000)[6:]
FUNCTION_OP_MFLO = intbv(0b010010)[6:]
FUNCTION_OP_MOVN = intbv(0b001011)[6:]
FUNCTION_OP_MOVZ = intbv(0b001010)[6:]
FUNCTION_OP_MSUB = intbv(0b000100)[6:]
FUNCTION_OP_MSUBU = intbv(0b000101)[6:]
FUNCTION_OP_MTHI = intbv(0b010001)[6:]
FUNCTION_OP_MTLO = intbv(0b010011)[6:]
FUNCTION_OP_MULT = intbv(0b011000)[6:]
FUNCTION_OP_MULTU = intbv(0b011001)[6:]
FUNCTION_OP_NOR = intbv(0b100111)[6:]
FUNCTION_OP_OR = intbv(0b100101)[6:]
FUNCTION_OP_SLL = intbv(0b000000)[6:]
FUNCTION_OP_SLLV = intbv(0b000100)[6:]
FUNCTION_OP_SLT = intbv(0b101010)[6:]
FUNCTION_OP_SLTU = intbv(0b101011)[6:]
FUNCTION_OP_SRA = intbv(0b000011)[6:]
FUNCTION_OP_SRAV = intbv(0b000111)[6:]
FUNCTION_OP_SRL = intbv(0b000010)[6:]
FUNCTION_OP_SRLV = intbv(0b000110)[6:]
FUNCTION_OP_SUB = intbv(0b100010)[6:]
FUNCTION_OP_SUBU = intbv(0b100011)[6:]
FUNCTION_OP_SYSCALL = intbv(0b001100)[6:]
FUNCTION_OP_TEQ = intbv(0b110100)[6:]
FUNCTION_OP_TGE = intbv(0b110000)[6:]
FUNCTION_OP_TGEU = intbv(0b110001)[6:]
FUNCTION_OP_TLT = intbv(0b110010)[6:]
FUNCTION_OP_TLTU = intbv(0b110011)[6:]
FUNCTION_OP_TNE = intbv(0b110110)[6:]
FUNCTION_OP_XOR = intbv(0b100110)[6:]

# ------------------------------------------------------------------------------
# Branch >, <, =zero (and link), traps: Rt
# ------------------------------------------------------------------------------
RT_OP_BGEZ = intbv(0b00001)[5:]
RT_OP_BGEZAL = intbv(0b10001)[5:]
RT_OP_BLTZ = intbv(0b00000)[5:]
RT_OP_BLTZAL = intbv(0b10000)[5:]
RT_OP_TEQI = intbv(0b01100)[5:]
RT_OP_TGEI = intbv(0b01000)[5:]
RT_OP_TGEIU = intbv(0b01001)[5:]
RT_OP_TLTI = intbv(0b01010)[5:]
RT_OP_TLTIU = intbv(0b01011)[5:]
RT_OP_TNEI = intbv(0b01110)[5:]

# ------------------------------------------------------------------------------
# Rs field for Coprocessor instructions
# ------------------------------------------------------------------------------
RS_OP_MFC = intbv(0b00000)[5:]
RS_OP_MTC = intbv(0x00100)[5:]

# ------------------------------------------------------------------------------
# ERET
# ------------------------------------------------------------------------------
RS_OP_ERET = intbv(0b10000)[5:]
FUNTION_OP_ERET = intbv(0b011000)[6:]

# ------------------------------------------------------------------------------
# ALU Operations
# ------------------------------------------------------------------------------
ALU_OP_ADDU = intbv(0)[5:]
ALU_OP_ADD = intbv(1)[5:]
ALU_OP_SUB = intbv(2)[5:]
ALU_OP_SUBU = intbv(3)[5:]
ALU_OP_AND = intbv(4)[5:]
ALU_OP_MULS = intbv(5)[5:]
ALU_OP_MULU = intbv(6)[5:]
ALU_OP_NOR = intbv(7)[5:]
ALU_OP_OR = intbv(8)[5:]
ALU_OP_SLL = intbv(9)[5:]
ALU_OP_SRA = intbv(10)[5:]
ALU_OP_SRL = intbv(11)[5:]
ALU_OP_XOR = intbv(12)[5:]
ALU_OP_MFHI = intbv(13)[5:]
ALU_OP_MFLO = intbv(14)[5:]
ALU_OP_MTHI = intbv(15)[5:]
ALU_OP_MTLO = intbv(16)[5:]
ALU_OP_SLT = intbv(17)[5:]
ALU_OP_SLTU = intbv(18)[5:]
ALU_OP_DIV = intbv(19)[5:]
ALU_OP_DIVU = intbv(20)[5:]
ALU_OP_CLO = intbv(21)[5:]
ALU_OP_CLZ = intbv(22)[5:]
ALU_OP_MADD = intbv(23)[5:]
ALU_OP_MADDU = intbv(24)[5:]
ALU_OP_MSUB = intbv(25)[5:]
ALU_OP_MSUBU = intbv(26)[5:]
ALU_OP_A = intbv(27)[5:]
ALU_OP_B = intbv(28)[5:]

# ------------------------------------------------------------------------------
#
#    Exception.
#
#    All signals are active High.
#
#    ----------------------------------------------------------------------------
#        Bit     Meaning
#    ----------------------------------------------------------------------------
#        2  :    Instruction can cause exception @ ID
#        1  :    Instruction can cause exception @ EX
#        0  :    Instruction can cause exception @ MEM
#    ----------------------------------------------------------------------------
# ------------------------------------------------------------------------------
EXCEPTION_NONE = intbv(0b000)[3:]
EXCEPTION_ID = intbv(0b100)[3:]
EXCEPTION_EX = intbv(0b010)[3:]
EXCEPTION_MEM = intbv(0b001)[3:]

EXC_ADD = EXCEPTION_EX
EXC_ADDI = EXCEPTION_EX
EXC_ADDIU = EXCEPTION_NONE
EXC_ADDU = EXCEPTION_NONE
EXC_AND = EXCEPTION_NONE
EXC_ANDI = EXCEPTION_NONE
EXC_BEQ = EXCEPTION_NONE
EXC_BGEZ = EXCEPTION_NONE
EXC_BGEZAL = EXCEPTION_NONE
EXC_BGTZ = EXCEPTION_NONE
EXC_BLEZ = EXCEPTION_NONE
EXC_BLTZ = EXCEPTION_NONE
EXC_BLTZAL = EXCEPTION_NONE
EXC_BNE = EXCEPTION_NONE
EXC_BREAK = EXCEPTION_ID
EXC_CLO = EXCEPTION_NONE
EXC_CLZ = EXCEPTION_NONE
EXC_DIV = EXCEPTION_NONE
EXC_DIVU = EXCEPTION_NONE
EXC_ERET = EXCEPTION_ID
EXC_J = EXCEPTION_NONE
EXC_JAL = EXCEPTION_NONE
EXC_JALR = EXCEPTION_NONE
EXC_JR = EXCEPTION_NONE
EXC_LB = EXCEPTION_MEM
EXC_LBU = EXCEPTION_MEM
EXC_LH = EXCEPTION_MEM
EXC_LHU = EXCEPTION_MEM
EXC_LL = EXCEPTION_MEM
EXC_LUI = EXCEPTION_NONE
EXC_LW = EXCEPTION_MEM
EXC_MADD = EXCEPTION_NONE
EXC_MADDU = EXCEPTION_NONE
EXC_MFC0 = EXCEPTION_ID
EXC_MFHI = EXCEPTION_NONE
EXC_MFLO = EXCEPTION_NONE
EXC_MOVN = EXCEPTION_NONE
EXC_MOVZ = EXCEPTION_NONE
EXC_MSUB = EXCEPTION_NONE
EXC_MSUBU = EXCEPTION_NONE
EXC_MTC0 = EXCEPTION_ID
EXC_MTHI = EXCEPTION_NONE
EXC_MTLO = EXCEPTION_NONE
EXC_MULT = EXCEPTION_NONE
EXC_MULTU = EXCEPTION_NONE
EXC_NOR = EXCEPTION_NONE
EXC_OR = EXCEPTION_NONE
EXC_ORI = EXCEPTION_NONE
EXC_SB = EXCEPTION_MEM
EXC_SC = EXCEPTION_MEM
EXC_SH = EXCEPTION_MEM
EXC_SLL = EXCEPTION_NONE
EXC_SLLV = EXCEPTION_NONE
EXC_SLT = EXCEPTION_NONE
EXC_SLTI = EXCEPTION_NONE
EXC_SLTIU = EXCEPTION_NONE
EXC_SLTU = EXCEPTION_NONE
EXC_SRA = EXCEPTION_NONE
EXC_SRAV = EXCEPTION_NONE
EXC_SRL = EXCEPTION_NONE
EXC_SRLV = EXCEPTION_NONE
EXC_SUB = EXCEPTION_EX
EXC_SUBU = EXCEPTION_EX
EXC_SW = EXCEPTION_MEM
EXC_SYSCALL = EXCEPTION_ID
EXC_TEQ = EXCEPTION_MEM         # Requieres result from EX, so it triggers in the MEM stage
EXC_TEQI = EXCEPTION_MEM         # Requieres result from EX, so it triggers in the MEM stage
EXC_TGE = EXCEPTION_MEM         # Requieres result from EX, so it triggers in the MEM stage
EXC_TGEI = EXCEPTION_MEM         # Requieres result from EX, so it triggers in the MEM stage
EXC_TGEIU = EXCEPTION_MEM         # Requieres result from EX, so it triggers in the MEM stage
EXC_TGEU = EXCEPTION_MEM         # Requieres result from EX, so it triggers in the MEM stage
EXC_TLT = EXCEPTION_MEM         # Requieres result from EX, so it triggers in the MEM stage
EXC_TLTI = EXCEPTION_MEM         # Requieres result from EX, so it triggers in the MEM stage
EXC_TLTIU = EXCEPTION_MEM         # Requieres result from EX, so it triggers in the MEM stage
EXC_TLTU = EXCEPTION_MEM         # Requieres result from EX, so it triggers in the MEM stage
EXC_TNE = EXCEPTION_MEM         # Requieres result from EX, so it triggers in the MEM stage
EXC_TNEI = EXCEPTION_MEM         # Requieres result from EX, so it triggers in the MEM stage
EXC_XOR = EXCEPTION_NONE
EXC_XORI = EXCEPTION_NONE

# ------------------------------------------------------------------------------
#     Hazard and forwarding signals.
#
#     All signals are Active High.
#
#     ------------
#     Bit  Meaning
#     ------------
#     7:   Wants Rs by ID
#     6:   Needs Rs by ID
#     5:   Wants Rt by ID
#     4:   Needs Rt by ID
#     3:   Wants Rs by EX
#     2:   Needs Rs by EX
#     1:   Wants Rt by EX
#     0:   Needs Rt by EX
# ------------------------------------------------------------------------------
HAZ_NOTHING = intbv(0b00000000)[8:]      # Jumps, Lui, Mfhi/lo, special, etc.
HAZ_ID_RS_ID_RT = intbv(0b11110000)[8:]  # Beq, Bne, Traps
HAZ_ID_RS = intbv(0b11000000)[8:]        # Most branches, Jumps to registers
HAZ_ID_RT = intbv(0b00110000)[8:]        # Mtc0
HAZ_ID_RT_EX_RS = intbv(0b10111100)[8:]  # Movn, Movz
HAZ_EX_RS_EX_RT = intbv(0b10101111)[8:]  # Many R-Type ops
HAZ_EX_RS = intbv(0b10001100)[8:]        # Immediates: Loads, Clo/z, Mthi/lo, etc.
HAZ_EX_RS_W_RT = intbv(0b10101110)[8:]   # Stores
HAZ_EX_RT = intbv(0b00100011)[8:]        # Shifts using Shamt field

HAZ_ADD = HAZ_EX_RS_EX_RT
HAZ_ADDI = HAZ_EX_RS
HAZ_ADDIU = HAZ_EX_RS
HAZ_ADDU = HAZ_EX_RS_EX_RT
HAZ_AND = HAZ_EX_RS_EX_RT
HAZ_ANDI = HAZ_EX_RS
HAZ_BEQ = HAZ_ID_RS_ID_RT
HAZ_BGEZ = HAZ_ID_RS
HAZ_BGEZAL = HAZ_ID_RS
HAZ_BGTZ = HAZ_ID_RS
HAZ_BLEZ = HAZ_ID_RS
HAZ_BLTZ = HAZ_ID_RS
HAZ_BLTZAL = HAZ_ID_RS
HAZ_BNE = HAZ_ID_RS_ID_RT
HAZ_BREAK = HAZ_NOTHING
HAZ_CLO = HAZ_EX_RS
HAZ_CLZ = HAZ_EX_RS
HAZ_DIV = HAZ_EX_RS_EX_RT
HAZ_DIVU = HAZ_EX_RS_EX_RT
HAZ_ERET = HAZ_NOTHING
HAZ_J = HAZ_NOTHING
HAZ_JAL = HAZ_NOTHING
HAZ_JALR = HAZ_ID_RS
HAZ_JR = HAZ_ID_RS
HAZ_LB = HAZ_EX_RS
HAZ_LBU = HAZ_EX_RS
HAZ_LH = HAZ_EX_RS
HAZ_LHU = HAZ_EX_RS
HAZ_LL = HAZ_EX_RS
HAZ_LUI = HAZ_NOTHING
HAZ_LW = HAZ_EX_RS
HAZ_MADD = HAZ_EX_RS_EX_RT
HAZ_MADDU = HAZ_EX_RS_EX_RT
HAZ_MFC0 = HAZ_NOTHING
HAZ_MFHI = HAZ_NOTHING
HAZ_MFLO = HAZ_NOTHING
HAZ_MOVN = HAZ_ID_RT_EX_RS
HAZ_MOVZ = HAZ_ID_RT_EX_RS
HAZ_MSUB = HAZ_EX_RS_EX_RT
HAZ_MSUBU = HAZ_EX_RS_EX_RT
HAZ_MTC0 = HAZ_ID_RT
HAZ_MTHI = HAZ_EX_RS
HAZ_MTLO = HAZ_EX_RS
HAZ_MULT = HAZ_EX_RS_EX_RT
HAZ_MULTU = HAZ_EX_RS_EX_RT
HAZ_NOR = HAZ_EX_RS_EX_RT
HAZ_OR = HAZ_EX_RS_EX_RT
HAZ_ORI = HAZ_EX_RS
HAZ_SB = HAZ_EX_RS_W_RT
HAZ_SC = HAZ_EX_RS_W_RT
HAZ_SH = HAZ_EX_RS_W_RT
HAZ_SLL = HAZ_EX_RT
HAZ_SLLV = HAZ_EX_RS_EX_RT
HAZ_SLT = HAZ_EX_RS_EX_RT
HAZ_SLTI = HAZ_EX_RS
HAZ_SLTIU = HAZ_EX_RS
HAZ_SLTU = HAZ_EX_RS_EX_RT
HAZ_SRA = HAZ_EX_RT
HAZ_SRAV = HAZ_EX_RS_EX_RT
HAZ_SRL = HAZ_EX_RT
HAZ_SRLV = HAZ_EX_RS_EX_RT
HAZ_SUB = HAZ_EX_RS_EX_RT
HAZ_SUBU = HAZ_EX_RS_EX_RT
HAZ_SW = HAZ_EX_RS_W_RT
HAZ_SYSCALL = HAZ_NOTHING
HAZ_TEQ = HAZ_EX_RS_EX_RT
HAZ_TEQI = HAZ_EX_RS
HAZ_TGE = HAZ_EX_RS_EX_RT
HAZ_TGEI = HAZ_EX_RS
HAZ_TGEIU = HAZ_EX_RS
HAZ_TGEU = HAZ_EX_RS_EX_RT
HAZ_TLT = HAZ_EX_RS_EX_RT
HAZ_TLTI = HAZ_EX_RS
HAZ_TLTIU = HAZ_EX_RS
HAZ_TLTU = HAZ_EX_RS_EX_RT
HAZ_TNE = HAZ_EX_RS_EX_RT
HAZ_TNEI = HAZ_EX_RS
HAZ_XOR = HAZ_EX_RS_EX_RT
HAZ_XORI = HAZ_EX_RS

# ------------------------------------------------------------------------------
#   Datapath controls.
#   All signals are active High.
#   ----------------------------------------------------------------------------
#       Bit     Name                Description
#   ----------------------------------------------------------------------------
#       31 :                            Wants Rs by ID
#       30 :                            Needs Rs by ID
#       29 :                            Wants Rt by ID
#       28 :                            Needs Rt by ID
#       27 :                            Wants Rs by EX
#       26 :                            Needs Rs by EX
#       25 :                            Wants Rt by EX
#       24 :                            Needs Rt by EX
#       -------------------------------
#       23 :    id_id_exception_source  Instruction can cause exception @ ID
#       22 :    id_ex_exception_source  Instruction can cause exception @ EX
#       21 :    id_mem_exception_source Instruction can cause exception @ MEM
#       -------------------------------
#       20 :    id_alu_operation        Operation to execute.
#       19 :    .
#       18 :    .
#       17 :    .
#       16 :    .
#       -------------------------------
#       15:     id_trap                 Trap instruction
#       14:     id_trap_condition       Condition: ALU result = 0 (0), ALU result != 0 (1)
#       -------------------------------
#       13 :    id_gpr_we               Write enable (GPR)
#       12 :    id_mem_to_gpr_select    Select data: ALU(0), MEM(1)
#       -------------------------------
#       11 :    id_alu_port_a_select    Select: Rs(0), shamt(1), 0x04(2), 0x10(3)
#       10 :    .
#       9  :    id_alu_port_b_select    Select: Rt(0), S/ZImm16(1), PCAdd4(2), CP0(3)
#       8  :    .
#       7  :    id_gpr_wa_select        Select register: Rd(0), Rt(1), 31(2)
#       6  :    .
#       -------------------------------
#       5  :    id_jump                 Jump instruction
#       4  :    id_branch               Branch instruction
#       -------------------------------
#       3  :    id_mem_write            Write to data memory
#       2  :    id_mem_byte             Enable read/write one byte
#       1  :    id_mem_halfword         Enable read/write 2 bytes (16 bits data)
#       0  :    id_mem_data_sign_ext    Zero extend data (0) or Sign extend data (1)
#   ----------------------------------------------------------------------------
# ------------------------------------------------------------------------------
DP_NONE = concat(HAZ_NOTHING, EXCEPTION_NONE, ALU_OP_AND, intbv(0b0000000000000000)[16:])
DP_ADD = concat(HAZ_EX_RS_EX_RT, EXCEPTION_EX, ALU_OP_ADD, intbv(0b0010000000000000)[16:])
DP_ADDI = concat(HAZ_EX_RS, EXCEPTION_EX, ALU_OP_ADD, intbv(0b0010000101000000)[16:])
DP_ADDIU = concat(HAZ_EX_RS, EXCEPTION_NONE, ALU_OP_ADDU, intbv(0b0010000101000000)[16:])
DP_ADDU = concat(HAZ_EX_RS_EX_RT, EXCEPTION_NONE, ALU_OP_ADDU, intbv(0b0010000000000000)[16:])
DP_AND = concat(HAZ_EX_RS_EX_RT, EXCEPTION_NONE, ALU_OP_AND, intbv(0b0010000000000000)[16:])
DP_ANDI = concat(HAZ_EX_RS, EXCEPTION_NONE, ALU_OP_AND, intbv(0b0010000101000000)[16:])
DP_BEQ = concat(HAZ_ID_RS_ID_RT, EXCEPTION_NONE, ALU_OP_AND, intbv(0b0000000000010000)[16:])
DP_BGEZ = concat(HAZ_ID_RS, EXCEPTION_NONE, ALU_OP_AND, intbv(0b0000000000010000)[16:])
DP_BGEZAL = concat(HAZ_ID_RS, EXCEPTION_NONE, ALU_OP_ADD, intbv(0b0010101010010000)[16:])
DP_BGTZ = concat(HAZ_ID_RS, EXCEPTION_NONE, ALU_OP_AND, intbv(0b0000000000010000)[16:])
DP_BLEZ = concat(HAZ_ID_RS, EXCEPTION_NONE, ALU_OP_AND, intbv(0b0000000000010000)[16:])
DP_BLTZ = concat(HAZ_ID_RS, EXCEPTION_NONE, ALU_OP_AND, intbv(0b0000000000010000)[16:])
DP_BLTZAL = concat(HAZ_ID_RS, EXCEPTION_NONE, ALU_OP_ADD, intbv(0b0010101010010000)[16:])
DP_BNE = concat(HAZ_ID_RS_ID_RT, EXCEPTION_NONE, ALU_OP_AND, intbv(0b0000000000010000)[16:])
DP_BREAK = concat(HAZ_NOTHING, EXCEPTION_ID, ALU_OP_AND, intbv(0b0000000000000000)[16:])
DP_CLO = concat(HAZ_EX_RS, EXCEPTION_NONE, ALU_OP_CLO, intbv(0b0010000000000000)[16:])
DP_CLZ = concat(HAZ_EX_RS, EXCEPTION_NONE, ALU_OP_CLZ, intbv(0b0010000000000000)[16:])
DP_DIV = concat(HAZ_EX_RS_EX_RT, EXCEPTION_NONE, ALU_OP_DIV, intbv(0b0000000000000000)[16:])
DP_DIVU = concat(HAZ_EX_RS_EX_RT, EXCEPTION_NONE, ALU_OP_DIVU, intbv(0b0000000000000000)[16:])
DP_ERET = concat(HAZ_NOTHING, EXCEPTION_ID, ALU_OP_AND, intbv(0b0000000000000000)[16:])
DP_J = concat(HAZ_NOTHING, EXCEPTION_NONE, ALU_OP_AND, intbv(0b0000000000100000)[16:])
DP_JAL = concat(HAZ_NOTHING, EXCEPTION_NONE, ALU_OP_ADD, intbv(0b0010101010100000)[16:])
DP_JALR = concat(HAZ_ID_RS, EXCEPTION_NONE, ALU_OP_ADD, intbv(0b0010101010010000)[16:])
DP_JR = concat(HAZ_ID_RS, EXCEPTION_NONE, ALU_OP_AND, intbv(0b0000000000010000)[16:])
DP_LB = concat(HAZ_EX_RS, EXCEPTION_MEM, ALU_OP_ADDU, intbv(0b0011000101000101)[16:])
DP_LBU = concat(HAZ_EX_RS, EXCEPTION_MEM, ALU_OP_ADDU, intbv(0b0011000101000100)[16:])
DP_LH = concat(HAZ_EX_RS, EXCEPTION_MEM, ALU_OP_ADDU, intbv(0b0011000101000011)[16:])
DP_LHU = concat(HAZ_EX_RS, EXCEPTION_MEM, ALU_OP_ADDU, intbv(0b0011000101000010)[16:])
DP_LL = concat(HAZ_EX_RS, EXCEPTION_MEM, ALU_OP_ADDU, intbv(0b0011000101000000)[16:])
DP_LUI = concat(HAZ_NOTHING, EXCEPTION_NONE, ALU_OP_SLL, intbv(0b0010110101000000)[16:])
DP_LW = concat(HAZ_EX_RS, EXCEPTION_MEM, ALU_OP_ADDU, intbv(0b0011000101000000)[16:])
DP_MADD = concat(HAZ_EX_RS_EX_RT, EXCEPTION_NONE, ALU_OP_MADD, intbv(0b0000000000000000)[16:])
DP_MADDU = concat(HAZ_EX_RS_EX_RT, EXCEPTION_NONE, ALU_OP_MADDU, intbv(0b0000000000000000)[16:])
DP_MFC0 = concat(HAZ_NOTHING, EXCEPTION_ID, ALU_OP_B, intbv(0b0010001101000000)[16:])
DP_MFHI = concat(HAZ_NOTHING, EXCEPTION_NONE, ALU_OP_MFHI, intbv(0b0010000000000000)[16:])
DP_MFLO = concat(HAZ_NOTHING, EXCEPTION_NONE, ALU_OP_MFLO, intbv(0b0010000000000000)[16:])
DP_MOVN = concat(HAZ_ID_RT_EX_RS, EXCEPTION_NONE, ALU_OP_A, intbv(0b0000000000000000)[16:])
DP_MOVZ = concat(HAZ_ID_RT_EX_RS, EXCEPTION_NONE, ALU_OP_A, intbv(0b0000000000000000)[16:])
DP_MSUB = concat(HAZ_EX_RS_EX_RT, EXCEPTION_NONE, ALU_OP_MSUB, intbv(0b0000000000000000)[16:])
DP_MSUBU = concat(HAZ_EX_RS_EX_RT, EXCEPTION_NONE, ALU_OP_MSUBU, intbv(0b0000000000000000)[16:])
DP_MTC0 = concat(HAZ_ID_RT, EXCEPTION_ID, ALU_OP_AND, intbv(0b0000000000000000)[16:])
DP_MTHI = concat(HAZ_EX_RS, EXCEPTION_NONE, ALU_OP_MTHI, intbv(0b0000000000000000)[16:])
DP_MTLO = concat(HAZ_EX_RS, EXCEPTION_NONE, ALU_OP_MTLO, intbv(0b0000000000000000)[16:])
DP_MULT = concat(HAZ_EX_RS_EX_RT, EXCEPTION_NONE, ALU_OP_MULS, intbv(0b0000000000000000)[16:])
DP_MULTU = concat(HAZ_EX_RS_EX_RT, EXCEPTION_NONE, ALU_OP_MULU, intbv(0b0000000000000000)[16:])
DP_NOR = concat(HAZ_EX_RS_EX_RT, EXCEPTION_NONE, ALU_OP_NOR, intbv(0b0010000000000000)[16:])
DP_OR = concat(HAZ_EX_RS_EX_RT, EXCEPTION_NONE, ALU_OP_OR, intbv(0b0010000000000000)[16:])
DP_ORI = concat(HAZ_EX_RS, EXCEPTION_NONE, ALU_OP_OR, intbv(0b0010000101000000)[16:])
DP_SB = concat(HAZ_EX_RS_W_RT, EXCEPTION_MEM, ALU_OP_ADDU, intbv(0b0000000100001100)[16:])
DP_SC = concat(HAZ_EX_RS_W_RT, EXCEPTION_MEM, ALU_OP_ADDU, intbv(0b0011000101001000)[16:])
DP_SH = concat(HAZ_EX_RS_W_RT, EXCEPTION_MEM, ALU_OP_ADDU, intbv(0b0000000100001010)[16:])
DP_SLL = concat(HAZ_EX_RT, EXCEPTION_NONE, ALU_OP_SLL, intbv(0b0010010000000000)[16:])
DP_SLLV = concat(HAZ_EX_RS_EX_RT, EXCEPTION_NONE, ALU_OP_SLL, intbv(0b0010000000000000)[16:])
DP_SLT = concat(HAZ_EX_RS_EX_RT, EXCEPTION_NONE, ALU_OP_SLT, intbv(0b0010000000000000)[16:])
DP_SLTI = concat(HAZ_EX_RS, EXCEPTION_NONE, ALU_OP_SLT, intbv(0b0010000101000000)[16:])
DP_SLTIU = concat(HAZ_EX_RS, EXCEPTION_NONE, ALU_OP_SLTU, intbv(0b0010000101000000)[16:])
DP_SLTU = concat(HAZ_EX_RS_EX_RT, EXCEPTION_NONE, ALU_OP_SLTU, intbv(0b0010000000000000)[16:])
DP_SRA = concat(HAZ_EX_RT, EXCEPTION_NONE, ALU_OP_SRA, intbv(0b0010010000000000)[16:])
DP_SRAV = concat(HAZ_EX_RS_EX_RT, EXCEPTION_NONE, ALU_OP_SRA, intbv(0b0010000000000000)[16:])
DP_SRL = concat(HAZ_EX_RT, EXCEPTION_NONE, ALU_OP_SRL, intbv(0b0010010000000000)[16:])
DP_SRLV = concat(HAZ_EX_RS_EX_RT, EXCEPTION_NONE, ALU_OP_SRL, intbv(0b0010000000000000)[16:])
DP_SUB = concat(HAZ_EX_RS_EX_RT, EXCEPTION_EX, ALU_OP_SUB, intbv(0b0010000000000000)[16:])
DP_SUBU = concat(HAZ_EX_RS_EX_RT, EXCEPTION_EX, ALU_OP_SUBU, intbv(0b0010000000000000)[16:])
DP_SW = concat(HAZ_EX_RS_W_RT, EXCEPTION_MEM, ALU_OP_ADDU, intbv(0b0000000100001000)[16:])
DP_SYSCALL = concat(HAZ_NOTHING, EXCEPTION_ID, ALU_OP_ADDU, intbv(0b0000000000000000)[16:])
DP_TEQ = concat(HAZ_EX_RS_EX_RT, EXCEPTION_MEM, ALU_OP_SUBU, intbv(0b1000000000000000)[16:])
DP_TEQI = concat(HAZ_EX_RS, EXCEPTION_MEM, ALU_OP_SUBU, intbv(0b1000000000000000)[16:])
DP_TGE = concat(HAZ_EX_RS_EX_RT, EXCEPTION_MEM, ALU_OP_SLT, intbv(0b1000000000000000)[16:])
DP_TGEI = concat(HAZ_EX_RS, EXCEPTION_MEM, ALU_OP_SLT, intbv(0b1000000000000000)[16:])
DP_TGEIU = concat(HAZ_EX_RS, EXCEPTION_MEM, ALU_OP_SLTU, intbv(0b1000000000000000)[16:])
DP_TGEU = concat(HAZ_EX_RS_EX_RT, EXCEPTION_MEM, ALU_OP_SLTU, intbv(0b1000000000000000)[16:])
DP_TLT = concat(HAZ_EX_RS_EX_RT, EXCEPTION_MEM, ALU_OP_SLT,  intbv(0b1100000000000000)[16:])
DP_TLTI = concat(HAZ_EX_RS, EXCEPTION_MEM, ALU_OP_SLT, intbv(0b1100000000000000)[16:])
DP_TLTIU = concat(HAZ_EX_RS, EXCEPTION_MEM, ALU_OP_SLTU, intbv(0b1100000000000000)[16:])
DP_TLTU = concat(HAZ_EX_RS_EX_RT, EXCEPTION_MEM, ALU_OP_SLTU, intbv(0b1100000000000000)[16:])
DP_TNE = concat(HAZ_EX_RS_EX_RT, EXCEPTION_MEM, ALU_OP_SUBU, intbv(0b1100000000000000)[16:])
DP_TNEI = concat(HAZ_EX_RS, EXCEPTION_MEM, ALU_OP_SUBU, intbv(0b1100000000000000)[16:])
DP_XOR = concat(HAZ_EX_RS_EX_RT, EXCEPTION_NONE, ALU_OP_XOR, intbv(0b0010000000000000)[16:])
DP_XORI = concat(HAZ_EX_RS, EXCEPTION_NONE, ALU_OP_XOR, intbv(0b0010000101000000)[16:])

# Local Variables:
# flycheck-flake8-maximum-line-length: 120
# End:
