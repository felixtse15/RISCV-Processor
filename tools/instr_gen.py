#!/usr/bin/env python3

# This program generates a text file containing a sequence of 16 random hexadecimal instructions to verify the RISCV Processor's 
# functionality.
#
# Author: Felix Tse
# Last Edit: 7/14/25
#
#

import random



# Some constants
SIZE = 16
INSTR_WEIGHTS = [20, 8, 2, 1, 1, 1, 4, 1, 2]
INSTR_TYPES = ['arithmeticimm', 'register', 'branch','jalr', 'jal', 'lw', 'sw', 'lui', 'auipc']
ARITHMETICIMM = ['addi', 'slli', 'slti', 'sltiu', 'xori', 'srli', 'ori', 'andi']
REGISTER = ['add', 'sll', 'slt', 'sltu', 'xor', 'srl', 'or', 'and']
BRANCH = ['beq', 'bne', 'ERROR', 'ERROR', 'blt', 'bge']




# Return a list containing 16 types of instructions, generated based on weighted possibilities
def type_list():
    type_list = random.choices(INSTR_TYPES, INSTR_WEIGHTS, k = SIZE)
    return type_list



# Return a random register number from available registers (s0, s1, s2-11, t3-6)
def rand_reg():
    available_registers = [0, 8, 9] + list(range(18,31))
    r = random.choice(available_registers)
    return(format(r, '05b'))



# Return a random register number not including 0 for register destination
def rand_rd():
    rd = '00000'
    while rd == '00000':
        rd = rand_reg()
    return rd



# Return a random funct3
def rand_funct3():
    n = random.randint(0,7)
    return(format(n, '03b'))



# Return random unsigned 12-bit immediate
def rand_imm():
    n = random.choice(list(range(0, 2048)))
    return(format(n, '012b'))



# Return random unsigned 5-bit immediate
def rand_shift_imm():
    n = random.choice(list(range(0, 32)))
    return(format(n, '05b'))



# Return random immediate for branch instruction
def rand_branch_imm():
    fourmultiples = list(range(12, 61, 4))      # 12 since branch is detected in execute stage (two cycles = two instructions). 16 instructions so 64 is max PC
    n = random.choice(fourmultiples)
    return(format(n, '013b'))



# Return random immediate for jalr instruction
def rand_jalr_imm():
    n = rand_branch_imm()
    return(n[1:])



# Return random immediate for jal instruction
def rand_jal_imm():
    fourmultiples = list(range(12,61,4))
    n = random.choice(fourmultiples)
    return(format(n, '021b'))



# Return random immediate for upper instruction
def rand_upp_imm():
    n = random.choice(list(range(-262144, 262144)))
    return(format(n, '020b'))



# Generate instruction encoding for arithmetic immediate type instructions
def generate_arithmetic_instr():
    # Opcode is the same for all arithmetic immediate instructions
    opcode = '0010011'

    # Randomly assign funct3
    funct3 = rand_funct3()

    # Assign funct7 if possible
    if funct3 == '001':
        funct7 = '0000000'
    elif funct3 == '101':
        funct7 = random.choice(['0000000', '0000001'])
    else:
        funct7 = ''
    
    # Randomly assign immediate value within range
    if funct7 in('0000000', '0000001'):
        immediate = rand_shift_imm()
    else:
        immediate = rand_imm()

    # Randomly assign register source 1
    rs1 = rand_reg()

    # Randomly assign register destination, cannot be x0
    rd = rand_rd()

    # Concatenate to form 32-bit binary instruction as string
    instr = funct7 + immediate + rs1 + funct3 + rd + opcode

    # Print the exact instruction name for debugging purposes, based on funct3
    index = int(funct3, 2)
    name = ARITHMETICIMM[index]
    if index == 5:
        if funct7 == '0000000':
            name = ARITHMETICIMM[index]
        else:
            name = 'srai'

    print(name, int(rd, 2), int(rs1, 2), int(immediate,2)) 
    return instr



# Generate instruction encoding for register type instructions
def generate_register_instr():
    # Opcode is the same for all register instructions
    opcode = '0110011'

    # Randomly assign funct3
    funct3 = rand_funct3()

    # Assign funct7
    if funct3 == '000':
        funct7 = random.choice(['0000000', '0100000'])
    elif funct3 == '101':
        funct7 = random.choice(['0000000', '0100000'])
    else:
        funct7 = '0000000'
    
    # Randomly assign register source 1 and 2
    rs1 = rand_reg()
    rs2 = rand_reg()

    # Randomly assign register destination, cannot be x0
    rd = rand_rd()

    # Concatenate to form 32-bit binary instruction as string
    instr = funct7 + rs2 + rs1 + funct3 + rd + opcode

    # Print exact instruction for debugging purposes
    index = int(funct3, 2)
    name = REGISTER[index]
    if index == 0:
        if funct7 == '0000000':
            name = REGISTER[index]
        else:
            name = 'sub'
    elif index == 5:
        if funct7 == '0000000':
            name = REGISTER[index]
        else:
            name = 'sra'

    print(name, int(rd, 2), int(rs1, 2), int(rs2, 2))

    return instr



# Generate instruction encoding for branch instructions
def generate_branch_instr():
    # Opcode is the same for all branch instructions
    opcode = '1100011'

    # Randomly generate funct3
    funct3 = rand_funct3()
    while funct3 not in [0, 1, 4, 5]:
        funct3 = rand_funct3()

    # Generate random branch immediate. Reverse to make encoding easier
    imm = rand_branch_imm()
    imm_rev = imm[::-1]

    # Randomly generate rs1 and rs2
    rs1 = rand_reg()
    rs2 = rand_reg()

    # Concatenate to form 32-bit binary instruction as string
    instr = imm_rev[12] + imm_rev[5:11] + rs2 + rs1 + funct3 + imm_rev[1:5] + imm_rev[11] + opcode

    index = int(funct3, 2)
    name = BRANCH[index]

    print(name, int(rs1, 2), int(rs2, 2), int(imm, 2))

    return instr
    
# Generate instruction encoding for jump instructions
def generate_jump_instr(instr_type):
   
    # Based on whether it is jalr or jal
    if instr_type == 'jalr':
        opcode = '1100111'
        funct3 = '000'
        rs1 = rand_reg()
        rd = rand_rd()
        imm = rand_jalr_imm()
        instr = imm + rs1 + funct3 + rd + opcode
        print('jalr', int(rd, 2), int(rs1, 2), int(imm, 2))
    elif instr_type == 'jal':
        opcode = '1101111'
        rd = rand_rd()
        imm = rand_jal_imm()
        imm_rev = imm[::-1]
        instr = imm_rev[20] + imm_rev[1:11] + imm_rev[11] + imm_rev[12:20] + rd + opcode
        print('jal', int(rd, 2), int(imm, 2))
    else:
        printf('Error finding jump instruction')

    return instr

# Generate instruction encoding for lw instruction
def generate_lw_instr():
    opcode = '0000011'
    imm = rand_imm()
    rs1 = rand_reg()
    rd = rand_rd()
    funct3 = '010'
    instr = imm + rs1 + funct3 + rd + opcode
    print('lw', int(rd, 2), int(imm, 2), '(', int(rs1, 2), ')')
    return instr

# Generate instruction encoding for sw instruction
def generate_sw_instr():
    opcode = '0100011'
    funct3 = '010'
    rs1 = rand_reg()
    rs2 = rand_reg()
    imm = rand_imm()
    imm_rev = imm[::-1]
    instr = imm_rev[5:12] + rs2 + rs1 + funct3 + imm[0:5] + opcode
    print('sw', int(rs2, 2), int(imm, 2), '(', int(rs1, 2), ')')

    return instr

# Generate instruction encoding for upperimm instruction
def generate_upperimm_instr(instr_type):
    if instr_type == 'lui':
        opcode = '0110111'
    elif instr_type == 'auipc':
        opcode = '0010111'
    else:
        print('Error finding upperimm instruction')
    
    rd = rand_rd()
    upimm = rand_upp_imm()

    instr = upimm + rd + opcode
    print(instr_type, int(rd, 2), int(upimm, 2))
    
    return instr

# Decides how to encode bits into instruction based on type
def encode_instruction(instr_type):
    match instr_type:
        case 'arithmeticimm':
            return generate_arithmetic_instr()
        case 'register':
            return generate_register_instr()
        case 'branch':
            return generate_branch_instr()
        case 'jalr' | 'jal':
            return generate_jump_instr(instr_type)
        case 'lw':
            return generate_lw_instr()
        case 'sw':
            return generate_sw_instr()
        case 'lui' | 'auipc' :
            return generate_upperimm_instr(instr_type)
        case default:
            return 0



# Convert binary to hexadecimal
def bin_to_hex(bin_instr):
    num = int(bin_instr, 2)
    hex_str = format(num, '08X')
    return(hex_str)



# Main loop
def main():
    # Seed pseudorandom number generator 
    random.seed()
    print('starting main')
    
    typelist = type_list()
    with open('/mnt/d/projects/RISCV/tools/output/output3.txt', 'w') as f:     # Update this counter before you run the program -> 3
        for i in range(SIZE):
            instr = encode_instruction(typelist[i])
            print('Instr', i, 'binary', instr)
            instr = bin_to_hex(instr)
            print('Instr', i, 'hex', instr)
            f.write(instr + '\n')

    
if __name__ == '__main__':
    main()




