module instructionmem(input  logic [31:0] PCF,
					  output logic [31:0] InstrF);
		
	logic [31:0] RAM [63:0];
	initial
		$readmemh("D:/projects/RISCV/tools/input/input_10.txt", RAM);
	assign InstrF = RAM[PCF[31:2]];
endmodule
