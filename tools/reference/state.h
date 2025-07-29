#ifndef STATE_H
#define STATE_H

#define REGWIDTH 32
#define DATASIZE 256
#define INSTRNUM 20
#define HEXWIDTH 8
#define BINWIDTH 32

// Structure to hold architectural state elements of the processor
typedef struct {
	uint32_t pc;						// program counter
	uint32_t rfile[REGWIDTH];			// register file
	uint32_t dmem[DATASIZE];			// data memory
	uint32_t imem[INSTRNUM];			// instruction memory, inner array allocates for newline character
} cpu_t;

void init_cpu(cpu_t *state);
void decode_instr(cpu_t *state, uint32_t instr);


#endif
