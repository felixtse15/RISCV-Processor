#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include "state.h"
#include "types.h"



// Initialize the architectural state elements
void init_cpu(cpu_t *state) {
	state->pc = 0;
	for (int i = 0; i < REGWIDTH; i++) {
		state->rfile[i] = 0;
	}
	for (int i = 0; i < DATASIZE; i++) {
		state->dmem[i] = 0;
	}
	for (int i = 0; i < INSTRNUM; i++) {
		state->imem[i] = 0;
	}
}





void decode_instr(cpu_t *state, uint32_t instr) {
	uint8_t opcode = instr & 0x7F;		// bits [6:0]
	
	printf("PC: %d, ", state->pc);
	switch (opcode) {
		case 51:					// register type
			printf("register type instruction!\n");\
			reg(state, instr);
			state->pc += 4;
			return;
		case 19:					// arithmetic immediate
			printf("arithmetic immediate instruction!\n");
			imm(state, instr);
			state->pc += 4;
			return;
		case 99:					// branch
			printf("branch instruction!\n");
			branch(state, instr);
			return;
		case 3:						// lw
			printf("lw instruction!\n");
			lw(state, instr);
			state->pc += 4;
			return;
		case 35:					// sw
			printf("sw instruction!\n");
			sw(state, instr);
			state->pc += 4;
			return;
		case 103:					// jalr
			printf("jalr instruction!\n");
			jalr(state, instr);
			return;
		case 111:					// jal
			printf("jal instruction!\n");
			jal(state, instr);
			return;
		case 23:					// auipc
			printf("auipc instruction!\n");
			auipc(state, instr);
			state->pc += 4;
			return;
		case 55:					// lui
			printf("lui instruction!\n");
			lui(state, instr);
			state->pc += 4;
			return;
		default:
			printf("illegal or incorrect opcode\n") ;
			state->pc += 4;
			return;
	}
}