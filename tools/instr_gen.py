#!/usr/bin/env python3
# Copyright 2025 Felix Tse
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0


# This program generates a text file containing a sequence of 16 random hexadecimal instructions to verify the RISCV Processor's 
# functionality.
#
# Author: Felix Tse
# Last Edit: 7/28/25
# 
# v3: Bugfixing. Pseudorandom number generator would stall infinitely halfway through instruction generator, was due to funct3 in branch checking for 
# integers instead of strings. Ensured that jalr, jal and branch instructions are all 4-byte aligned. To ensure that sw memory location is in range, 
# fixed rs1 to x0, and imm range is between 0 and 256. There was a bug with jalr and jal where the value in the register and the immediate was less 
# than the current program counter (PC), resulting in a infinite loop. Fixed by adding a program counter and fixing rs1 in jalr to x0, checking in 
# jalr and jal instructions that instruction was greater than program counter. Added lower and upper bounds for jalr to prevent infinite loops from 
# target address going backwards.
#
#
# v2: It is practical to increase temporal locality by reading from registers and memory addresses that have recently been written to. To implement this, 
# two global arrays are added to the program to keep track of registers and memory locations that were written to. When a lw or sw instruction is 
# generated, the registers and memory locations, accordingly, will be selected from these arrays instead. All instructions besides
# immediate types will draw from these arrays, since immediates *almost always guarantee that a value other than 0 will be written. In order to guarantee 
# that the array will have at least one value before being drawn from, the first instruction must be a immediate type instruction and the last instruction 
# should be a sw instruction. Included jal and upper as exceptions since they only write to rd. Additionally, to adhere to temporal locality, lw will not
# be generated until at least one sw instruction has generated. 
#
#
# v1: Generates a random list of 16 types of instructions, where immediates and register types are weighted more heavily than others. 
# List contents are used as input to generate random instruction out of each# type category.Implemented custom functions for immediate generation for 
# each type of instructions. Fixed bugs involving sign conversion with to_sigbin() from_sigbin() functions, branch instruction name assignment with 
# padded 'ERROR' entries for correct index



import random
import time



# Some constants and global variables
INSTR_WEIGHTS     = [20, 7, 6, 1, 1, 2, 1, 1, 1,]                    # Immediate and register instructions more likely than jal and lw
INSTR_TYPES       = ['arithmeticimm', 'register', 'sw', 'lui', 'auipc', 'branch','jalr', 'jal', 'lw']
ARITHMETICIMM     = ['addi', 'slli', 'slti', 'sltiu', 'xori', 'srli', 'ori', 'andi']
REGISTER          = ['add', 'sll', 'slt', 'sltu', 'xor', 'srl', 'or', 'and']
BRANCH            = ['beq', 'bne', 'ERROR', 'ERROR', 'blt', 'bge']
INSTRNUM          = 20                                               # Number of instructions generated
LOC_REG_LIST      = []                                               # Stores registers that have recently been written to
LOC_MEM_LIST      = []                                               # List of a list, stores combinations of imm and rs1, effectively stores a memory address
IS_ITYPE          = True                                             # Flag for checking whether or not to read from LOC_REG_LIST
SW_OCCURRED       = False                                            # Flag for checking whether LOC_MEM_LIST is non-empty





# Return a list containing INSTRNUM - 2 types of instructions, generated based on weighted possibilities
def rand_type(state):
    global SW_OCCURRED
    
    if (SW_OCCURRED == True) and (state['pc'] <= 68):         
        type = random.choices(INSTR_TYPES, INSTR_WEIGHTS, k = 1)[0]
        
    elif ((SW_OCCURRED == False) and (state['pc'] <= 68)):
        # Exclude lw instruction and its weight until sw has occurred
        type = random.choices(INSTR_TYPES[0:8], INSTR_WEIGHTS[0:8], k = 1)[0]
        
    else:    
        # Exclude jump and branch instructions if there are only two instructions left
        type = random.choices(INSTR_TYPES[0:4], INSTR_WEIGHTS[0:4], k = 1)[0]   
        
    return type



# For upper immediate, debugging prints commented out
def to_sigbin(num):
    # print('to_sigbin num', num)
    
    if num < 0:
        flipped = ~num & ((1 << 20) -1)
        binary_num = (flipped + 1) & ((1 << 20) - 1)
        binary_string = format(binary_num, f'0{20}b')
        
    else:
        binary_string = format(num, '020b') 
        
    return binary_string


# For converting back from signed numbers
def from_sigbin(string):
    # print('from_sigbin string = ', string)
    
    bits = len(string) 
    value = int(string, 2)
    
    if string[0] == '1':
        value -= (1 << bits)
        
    return value


# Return a random register number from available registers (s0, s1, s2-11, t3-6)
def rand_reg():
    global IS_ITYPE
    flag = IS_ITYPE
    
    # print('rand reg flag = ', flag)
    
    if not flag:
        r = random.choice(LOC_REG_LIST)
        return r
        
    else:
        r = random.choice([0, 8, 9] + list(range(18, 31)))
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


# Return random unsigned immediate for sw
def rand_mem_imm():
    n = random.choice(list(range(0, 257, 4)))
    
    return(format(n, '012b'))



# Return random unsigned 5-bit immediate
def rand_shift_imm():
    n = random.choice(list(range(0, 32)))
    
    return(format(n, '05b'))



# Return random immediate for branch instruction
def rand_branch_imm(state):
    
    # At least 3 instructions to actually "skip" an instruction, otherwise pc will still be in order due to 3 cycle delay
    fourmultiples = list(range(16, (4 * (INSTRNUM - 2)) + 1, 4))      
    n = random.choice(fourmultiples)
    
    if (state['pc'] > ((4 * (INSTRNUM - 2)) - 16)):
        n = ((4 * (INSTRNUM - 2) - state['pc']))
        
    else:
        while ((n + state['pc']) > (4 * (INSTRNUM - 1))):
            n = random.choice(fourmultiples)
         
    return(format(n, '013b'))



# Return random immediate for jalr instruction
def rand_jalr_imm(state):
    fourmultiples = list(range(16, (4 * (INSTRNUM - 1)) + 1, 4))    
    n = random.choice(fourmultiples)
    
    if (state['pc'] + 16) < 76:
        while (n <= (state['pc'] + 16)):
            n = random.choice(fourmultiples)
            
    else:
        n = ((4 * (INSTRNUM - 2)))
        
    return(format(n, '012b'))



# Return random immediate for jal instruction
def rand_jal_imm(state):
    fourmultiples = list(range(16, (4 * (INSTRNUM - 1)) + 1, 4))
    n = random.choice(fourmultiples)
    
    if (state['pc'] > ((4 * (INSTRNUM - 2)) - 16)):
        n = ((4 * (INSTRNUM - 2) - state['pc']))
        
    else:
        while ((n + state['pc']) > (4 * (INSTRNUM - 1))):
            n = random.choice(fourmultiples)
            
    return(format(n, '021b'))



# Return random immediate for upper instruction
def rand_upp_imm():
    n = random.choice(list(range(-262144, 262144)))
    # print(n)
    
    return(to_sigbin(n))



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
    if rd not in LOC_REG_LIST:
        LOC_REG_LIST.append(rd)

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

    print(name, int(rd, 2), int(rs1, 2), int(immediate,2), IS_ITYPE) 
    
    return instr



# Generate instruction encoding for register type instructions
def generate_register_instr():
    
    # Set the flag to false 
    global IS_ITYPE
    IS_ITYPE = False

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
    
    # debugging
    print(name, int(rd, 2), int(rs1, 2), int(rs2, 2), IS_ITYPE)

    # Set flag back to true
    IS_ITYPE = True
    
    return instr



# Generate instruction encoding for branch instructions
def generate_branch_instr(state):
    
    # Set flag to false
    global IS_ITYPE
    IS_ITYPE = False
    
    # Opcode is the same for all branch instructions
    opcode = '1100011'

    # Randomly generate funct3
    funct3 = rand_funct3()
    while funct3 not in ['000', '001', '100', '101']:
        funct3 = rand_funct3()

    # Generate random branch immediate. Reverse to make encoding easier
    imm = rand_branch_imm(state)

    # Randomly generate rs1 and rs2
    rs1 = rand_reg()
    rs2 = rand_reg()

    # Concatenate to form 32-bit binary instruction as string
    instr = imm[0] + imm[2:8] + rs2 + rs1 + funct3 + imm[8:12] + imm[1] + opcode

    index = int(funct3, 2)
    name = BRANCH[index]
    
    # debugging
    print(name, int(rs1, 2), int(rs2, 2), int(imm, 2), IS_ITYPE)
    
    # Set flag back to true
    IS_ITYPE = True

    return instr
    
# Generate instruction encoding for jump instructions
def generate_jump_instr(instr_type, state):
    
    # Based on whether it is jalr or jal
    if instr_type == 'jalr':
        opcode = '1100111'
        funct3 = '000'
        rs1 = '00000'
        rd = rand_rd()
        
        if rd not in LOC_REG_LIST:
            LOC_REG_LIST.append(rd)
            
        imm = rand_jalr_imm(state)
        instr = imm + rs1 + funct3 + rd + opcode
        print('jalr', int(rd, 2), int(rs1, 2), int(imm, 2), IS_ITYPE)
        
    elif instr_type == 'jal':
        opcode = '1101111'
        rd = rand_rd()
        
        if rd not in LOC_REG_LIST:
            LOC_REG_LIST.append(rd)
            
        imm = rand_jal_imm(state)
        instr = imm[0] + imm[10:20] + imm[9] + imm[1:9] + rd + opcode
        print('jal', int(rd, 2), int(imm, 2), IS_ITYPE)     # This is an exception
        
    else:
        printf('Error finding jump instruction')

    return instr

# Generate instruction encoding for lw instruction
def generate_lw_instr():
    opcode = '0000011'
    rand_mem_loc = random.choice(LOC_MEM_LIST)
    imm = rand_mem_loc[0]
    rs1 = rand_mem_loc[1]
    rd = rand_rd()
    
    if rd not in LOC_REG_LIST:
        LOC_REG_LIST.append(rd)
        
    funct3 = '010'
    instr = imm + rs1 + funct3 + rd + opcode
    print('lw', int(rd, 2), int(imm, 2), '(', int(rs1, 2), ')', IS_ITYPE)
    
    return instr




# Generate instruction encoding for sw instruction
def generate_sw_instr():
    
    # Set some flags
    global IS_ITYPE
    global SW_OCCURRED
    IS_ITYPE = False
    
    if SW_OCCURRED == False:
        SW_OCCURRED = True
    
    opcode = '0100011'
    funct3 = '010'
    
    # Call rand_rd() instead to use read from LOC_REG_LIST and avoid reading from x0
    rs2 = rand_rd()     
    
    # imm has range of 0 to 256, fixing rs1 to 0 ensures that the memory address will always be within range
    imm = rand_mem_imm()
    rs1 = '00000'

    LOC_MEM_LIST.append([imm, rs1])
    
    # From C based indexing to python based indexing: [x, y] in C where z is total number of bits, in Python is [z - a - 1, z - b]
    instr = imm[0:7] + rs2 + rs1 + funct3 + imm[7:12] + opcode
    print('sw', int(rs2, 2), int(imm, 2), '(', int(rs1, 2), ')', IS_ITYPE)
    IS_ITYPE = True
    
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
    
    if rd not in LOC_REG_LIST:
        LOC_REG_LIST.append(rd)
        
    upimm = rand_upp_imm()
    instr = upimm + rd + opcode
    print(instr_type, int(rd, 2), from_sigbin(upimm), IS_ITYPE)
    
    return instr



# Decides how to encode bits into instruction based on type
def encode_instruction(instr_type, state):
    match instr_type:
        case 'arithmeticimm':
            return generate_arithmetic_instr()
        case 'register':
            return generate_register_instr()
        case 'branch':
            return generate_branch_instr(state)
        case 'jalr' | 'jal':
            return generate_jump_instr(instr_type, state)
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
    
    # Seed pseudorandom number generator with time based seed
    random.seed(int(time.time()))
    print('starting main')
    state = {'pc': 0};
    
    for i in range(10):
        print("Run", i+1, "***************\n");
        
        with open(f"/mnt/d/projects/RISCV/tools/input/input_{i+1}.txt", 'w') as f:     
        
            # Guarantee that the first instruction is arithmetic imm
            instr = generate_arithmetic_instr()     
            f.write(bin_to_hex(instr) + '\n')
            print('Instr 01', 'hex', bin_to_hex(instr))
            state['pc'] = 4;
            
            for i in range(INSTRNUM - 2):
                instr = encode_instruction(rand_type(state), state)
                instr = bin_to_hex(instr)
                print('Instr', format(i + 2, '02d'), 'hex', instr)
                f.write(instr + '\n')
                
                # Update program counter
                state['pc'] += 4;
            
            # Guarantee that final instruction is sw for debugging later
            instr = generate_sw_instr()                                                
            f.write(bin_to_hex(instr) + '\n')
            print('Instr', INSTRNUM, 'hex', bin_to_hex(instr))         

if __name__ == '__main__':
    main()
