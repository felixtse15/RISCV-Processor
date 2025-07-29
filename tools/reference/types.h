#ifndef TYPES_H
#define TYPES_H

#include "state.h"

void reg(cpu_t *state, uint32_t instr);
void imm(cpu_t *state, uint32_t instr);
void branch(cpu_t *state, uint32_t instr);
void lw(cpu_t *state, uint32_t instr);
void sw(cpu_t *state, uint32_t instr);
void jalr(cpu_t *state, uint32_t instr);
void jal(cpu_t *state, uint32_t instr);
void auipc(cpu_t *state, uint32_t instr);
void lui(cpu_t *state, uint32_t instr);


#endif