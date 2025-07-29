module top(input  logic        clk, reset,
		   output logic [31:0] WriteDataM, ALUResultM,
		   output logic 	   MemWriteM);

	logic [31:0] PCF, InstrF, ReadDataM;

	riscvprocessor rv1(.clk(clk), .reset(reset), .InstrF(InstrF), .ReadDataM(ReadDataM), .PCF(PCF), .WriteDataM(WriteDataM), .ALUResultM(ALUResultM), .MemWriteM(MemWriteM));
	
	instructionmem imem(.PCF(PCF), .InstrF(InstrF));

	datamem dmem(.clk(clk), .we(MemWriteM), .A(ALUResultM), .WD(WriteDataM), .RD(ReadDataM));

endmodule
