# RISC-V Processor
A 5-stage pipelined processor implemented in SystemVerilog and simulated in ModelSim. Additional Python, C, and Bash scripts
to support verification and automate workflows.

# Features
- 32-bit Instruction
- Implemented 29 integer instructions, including auipc, lui, jalr, beq 
- 5-stage pipeline: fetch, decode, execute, memory, writeback
- Hazard detection unit, implemented forward, flush and stall
- Overflow detection
  
# Microarchitecture
![Microarchitecture diagram](documentation/microarchitecture.jpg)

# Upcoming Changes
- Overflow handling
- Illegal/incorrect instruction handling
- Reduce jump penalty to one cycle by moving PC Target adder to decode stage
  
# References
[1] Digital Design and Computer Architecture RISC-V Edition by Sarah Harris, David Harris
