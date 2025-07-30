#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

#include "types.h"
#include "state.h"

void reg(cpu_t *state, uint32_t instr) {
	uint8_t rd = (instr & 0xF80) >> 7;
	uint8_t funct3 = (instr & 0x7000) >> 12;
	uint8_t rs1 = (instr & 0xF8000) >> 15;
	uint8_t rs2 = (instr & 0x1F00000) >> 20;
	uint8_t funct7 = (instr & 0xFE000000) >> 25;
	
	switch(funct3) {
		case 0:
			if(funct7 == 0) {
				state->rfile[rd] = state->rfile[rs1] + state->rfile[rs2];						// add
				printf("add %d, %d, %d: ", rd, rs1, rs2);
				break;
			}
			else {
				state->rfile[rd] = state->rfile[rs1] - state->rfile[rs2];						// sub
				printf("sub %d, %d, %d: ", rd, rs1, rs2);
				break;
			}
		case 1:
			state->rfile[rd] = state->rfile[rs1] << state->rfile[rs2];							// sll
			printf("sll %d, %d, %d: ", rd, rs1, rs2);
			break;
		case 2:
			state->rfile[rd] = ((int32_t)state->rfile[rs1] < (int32_t)state->rfile[rs2]);					// slt
			printf("slt %d, %d, %d: ", rd, rs1, rs2);
			break;
		case 3:																					
			state->rfile[rd] = (state->rfile[rs1] < state->rfile[rs2]);							// sltu 
			printf("sltu %d, %d, %d: ", rd, rs1, rs2);
			break;
		case 4:
			state->rfile[rd] = (state->rfile[rs1] ^ state->rfile[rs2]);							// xor
			printf("xor %d, %d, %d: ", rd, rs1, rs2);
			break;
		case 5:
			if (funct7 == 0) {
				state->rfile[rd] = (state->rfile[rs1] >> state->rfile[rs2]);						// srl
				printf("srl %d, %d, %d: ", rd, rs1, rs2);
				break;
			}
			else {
				state->rfile[rd] = ((int32_t)state->rfile[rs1] >> state->rfile[rs2]);					// sra
				printf("sra %d, %d, %d: ", rd, rs1, rs2);
				break;	
			}
		case 6:
			state->rfile[rd] = (state->rfile[rs1] | state->rfile[rs2]);							// or
			printf("sra %d, %d, %d: ", rd, rs1, rs2);
			break;
		case 7:
			state->rfile[rd] = (state->rfile[rs1] & state->rfile[rs2]);							// and
			printf("and %d, %d, %d: ", rd, rs1, rs2);
			break;
		default:
			printf("Illegal register instruction!\n");
			return;
	}
	printf("[%d] = %u\n", rd, state->rfile[rd]);
}

void imm(cpu_t *state, uint32_t instr) {
	uint8_t rd = (instr & 0xF80) >> 7;
	uint8_t funct3 = (instr & 0x7000) >> 12;
	uint8_t rs1 = (instr & 0xF8000) >> 15;
	int32_t imm = ((int32_t)instr >> 20);
	
	switch (funct3) {
		case 0:
			state->rfile[rd] = ((int32_t)state->rfile[rs1] + imm);					// addi
			printf("addi %d, %d, %d: ", rd, rs1, imm);
			break;
		case 1:
			state->rfile[rd] = ((int32_t)state->rfile[rs1] << imm);					// slli
			printf("slli %d, %d, %d: ", rd, rs1, imm);
			break;
		case 2:
			state->rfile[rd] = ((int32_t)state->rfile[rs1] < imm);					// slti
			printf("slti %d, %d, %d: ", rd, rs1, imm);
			break;
		case 3:																					
			state->rfile[rd] = (state->rfile[rs1] < (uint32_t)imm);					// sltiu 
			printf("sltiu %d, %d, %d: ", rd, rs1, imm);
			break;
		case 4:
			state->rfile[rd] = ((int32_t)state->rfile[rs1] ^ imm);					// xori
			printf("xori %d, %d, %d: ", rd, rs1, imm);
			break;
		case 5:
			uint8_t funct7 = (instr & 0xFE000000) >> 25;
			if (funct7 == 0) {
				state->rfile[rd] = (state->rfile[rs1] >> (uint32_t)imm);			// srli
				printf("srli %d, %d, %d: ", rd, rs1, imm);
				break;
			}
			else {
				state->rfile[rd] = ((int32_t)state->rfile[rs1] >> (uint32_t)imm);		// srai
				printf("srai %d, %d, %d: ", rd, rs1, imm);
				break;	
			}
		case 6:
			state->rfile[rd] = ((int32_t)state->rfile[rs1] | imm);					// ori
			printf("ori %d, %d, %d: ", rd, rs1, imm);
			break;
		case 7:
			state->rfile[rd] = ((int32_t)state->rfile[rs1] & imm);					// andi
			printf("andi %d, %d, %d: ", rd, rs1, imm);
			break;
		default:
			printf("Illegal immediate instruction!\n");
			return;
	}
	printf("[%d] = %u\n", rd, state->rfile[rd]);
}

void branch(cpu_t *state, uint32_t instr) {
	uint8_t funct3 = (instr & 0x7000) >> 12;
	uint8_t rs1 = (instr & 0xF8000) >> 15;
	uint8_t rs2 = (instr & 0x1F00000) >> 20;
	int32_t imm = 0;
	

	imm |= ((instr >> 31) & 0x1) << 12;  // imm[12] = bit 31
	imm |= ((instr >> 25) & 0x3F) << 5;  // imm[10:5] = bits 30:25
	imm |= ((instr >> 8) & 0xF) << 1;    // imm[4:1] = bits 11:8
	imm |= ((instr >> 7) & 0x1) << 11;   // imm[11] = bit 7

	// Now sign-extend from bit 12 (since imm is 13 bits: [12:1] plus 0 at LSB)
	imm = (imm << 19) >> 19;  // shift left then arithmetic shift right
	
	printf("funct3: %u, imm: %d", funct3, imm);
	switch(funct3) {
		case 0:
			printf("beq %u, %u, %d", rs1, rs2, imm);
			if (state->rfile[rs1] == state->rfile[rs2]) {		// beq
				printf("Beq branch taken! ");	
				state->pc = ((int32_t)state->pc + imm) & ~0x3;
				printf("Branch target: %u", state->pc);
			} else {
				state->pc += 4;
			}
			break;
		case 1:
			printf("bne %u, %u, %d", rs1, rs2, imm);
			if (state->rfile[rs1] != state->rfile[rs2]) {		// bne
				printf("Bne branch taken! ");	
				state->pc = ((int32_t)state->pc + imm) & ~0x3;
				printf("Branch target: %u", state->pc);
			} else {
				state->pc +=4;
			}
			break;
		case 4:
			printf("blt %u, %u, %d", rs1, rs2, imm);
			if (state->rfile[rs1] < state->rfile[rs2]) {		// blt
				printf("Blt branch taken! ");	
				state->pc = ((int32_t)state->pc + imm) & ~0x3;
				printf("Branch target: %u", state->pc);
			} else {
				state->pc += 4;
			}
			break;
		case 5:
			printf("bge %u, %u, %d", rs1, rs2, imm);
			if (state->rfile[rs1] >= state->rfile[rs2]) {		// bge
				printf("Bge branch taken! ");	
				state->pc = ((int32_t)state->pc + imm) & ~0x3;
				printf("Branch target: %u", state->pc);
			} else {
				state->pc += 4;
			}
			break;
	}
}

void lw(cpu_t *state, uint32_t instr) {
	uint8_t rd = (instr & 0xF80) >> 7;
	//uint8_t funct3 = (instr & 0x7000) >> 12;
	uint8_t rs1 = (instr & 0xF8000) >> 15;
	int32_t imm = ((int32_t)instr >> 20);
	
	// DEBUGGING
	printf("lw %u, %d(%u),", rd, imm, rs1);
	
	// Compute memory address and store value from memory into register
	uint32_t adr = state->rfile[rs1] + imm;
	state->rfile[rd] = state->dmem[adr];
	printf(" %u stored from adr %u\n", state->dmem[adr], adr);
}

void sw(cpu_t *state, uint32_t instr) {
	//uint8_t funct3 = (instr & 0x7000) >> 12;
	uint8_t rs1 = (instr & 0xF8000) >> 15;
	uint8_t rs2 = (instr & 0x1F00000) >> 20;
	int32_t imm = 0;
	
	
	// Extract bitfield
	imm |= ((instr >> 25) & 0x7F) << 5;  			// imm[11:5] = bits 31:25
	imm |= ((instr >> 7) & 0x1F);        			// imm[4:0]  = bits 11:7

	// Sign-extend to 32 bits if bit 11 (MSB of imm) is set
	if (imm & (1 << 11))
		imm |= 0xFFFFF000;
	
	// DEBUGGING
	printf("sw %u, %d(%u),", rs2, imm, rs1);
	
	// Compute the memory address and store value from register into memory
	uint32_t adr = state->rfile[rs1] + imm;
	state->dmem[adr] = state->rfile[rs2];
	printf(" %u stored at adr %u\n", state->rfile[rs2], adr);
}

void jalr(cpu_t *state, uint32_t instr) {
	uint8_t rd = (instr & 0xF80) >> 7;
	//uint8_t funct3 = (instr & 0x7000) >> 12;
	uint8_t rs1 = (instr & 0xF8000) >> 15;
	int32_t imm = ((int32_t)instr >> 20);
	
	state->rfile[rd] = state->pc + 4;
	state->pc = (state->rfile[rs1] + imm) & ~0x3;	// 4 byte aligned pc
	printf("Jump target address: %u\n", state->pc);
}

void jal(cpu_t *state, uint32_t instr) {
	uint8_t rd = (instr & 0xF80) >> 7;
	int32_t imm = 0;

	imm |= (instr & 0xFF000);         				// imm[19:12] → bits 19:12
	imm |= (instr & 0x80000000) >> 11; 				// imm[20]    → bit 31 → becomes bit 20
	imm |= (instr & 0x100000) >> 9;   				// imm[11]    → bit 20 → becomes bit 11
	imm |= (instr & 0x7FE00000) >> 20; 				// imm[10:1]  → bits 30:21 → becomes bits 10:1

	// Sign-extend to 32 bits
	if (imm & 0x00100000) imm |= 0xFFE00000;

	
	state->rfile[rd] = state->pc + 4;
	state->pc = (state->pc + imm) & ~0x3;			// 4 byte aligned pc
	printf("Jump target address: %u\n", state->pc);
}

void auipc(cpu_t *state, uint32_t instr) {
	uint8_t rd = (instr & 0xF80) >> 7;
	int32_t imm = ((int32_t)instr >> 12) << 12; 
	state->rfile[rd] = state->pc + imm;
	printf("auipc %d, %d", rd, imm);
	printf("Stored auipc: %u\n", state->rfile[rd]);
}

void lui(cpu_t *state, uint32_t instr) {
	uint8_t rd = (instr & 0xF80) >> 7;
	int32_t imm = ((int32_t)instr >> 12) << 12; 
	state->rfile[rd] = imm;
	printf("lui %d, %d: ", rd, imm);
	printf("Stored imm: %d\n", imm);
}

