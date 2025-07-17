// Main module of the single cycle pipelined processor
// Defines inputs and outputs of processor interfaced with external memories (Data/Instruction) in port list
// Instantiates controller, datapath, and hazardunit modules

module riscvprocessor(input  logic        clk, reset,
					  input  logic [31:0] InstrF,
					  input  logic [31:0] ReadDataM,
					  output logic [31:0] PCF,
					  output logic [31:0] WriteDataM,
					  output logic [31:0] ALUResultM,
					  output logic        MemWriteM);
					  
	logic        ALUSrcAE, RegWriteM, RegWriteW, ZEROE, SIGNE, PCSrcE, PCJumpSrcE;
	logic [1:0]  ALUSrcBE;
	logic [31:0] InstrD;
	logic [4:0]  Rs1D, Rs2D, Rs1E, Rs2E, RdE, RdM, RdW;
	logic [3:0]  ALUControlE;
	logic [2:0]  ImmSrcD;
	logic [1:0]  ResultSrcW;
	logic [1:0]  ForwardAE, ForwardBE;
	logic        StallD, StallF, FlushD, FlushE, ResultSrcE0;
	
	controller c(.clk(clk), .reset(reset), .opcode(InstrD[6:0]), .funct3(InstrD[14:12]), .funct7b5(InstrD[30]), .ZEROE(ZEROE), .SIGNE(SIGNE), .FlushE(FlushE), .ResultSrcE0(ResultSrcE0), .ResultSrcW(ResultSrcW), .MemWriteM(MemWriteM), .PCJumpSrcE(PCJumpSrcE), .PCSrcE(PCSrcE), .ALUSrcAE(ALUSrcAE), .ALUSrcBE(ALUSrcBE), .RegWriteM(RegWriteM), .RegWriteW(RegWriteW), .ImmSrcD(ImmSrcD), .ALUControlE(ALUControlE));
	
	datapath d(.clk(clk), .reset(reset), .ResultSrcW(ResultSrcW), .PCJumpSrcE(PCJumpSrcE), .PCSrcE(PCSrcE), .ALUSrcAE(ALUSrcAE), .ALUSrcBE(ALUSrcBE), .RegWriteW(RegWriteW), .ImmSrcD(ImmSrcD), .ALUControlE(ALUControlE), .InstrF(InstrF), .ReadDataM(ReadDataM), .ForwardAE(ForwardAE), .ForwardBE(ForwardBE), .StallD(StallD), .StallF(StallF), .FlushD(FlushD), .FlushE(FlushE), .Rs1D(Rs1D), .Rs2D(Rs2D), .Rs1E(Rs1E), .Rs2E(Rs2E), .RdE(RdE), .RdM(RdM), .RdW(RdW), .InstrD(InstrD), .ZEROE(ZEROE), .SIGNE(SIGNE), .PCF(PCF), .ALUResultM(ALUResultM), .WriteDataM(WriteDataM));
	
	hazardunit h(.Rs1D(Rs1D), .Rs2D(Rs2D), .Rs1E(Rs1E), .Rs2E(Rs2E), .RdE(RdE), .RdM(RdM), .RdW(RdW), .ResultSrcE0(ResultSrcE0), .RegWriteM(RegWriteM), .RegWriteW(RegWriteW), .PCSrcE(PCSrcE), .StallF(StallF), .StallD(StallD), .FlushD(FlushD), .FlushE(FlushE), .ForwardAE(ForwardAE), .ForwardBE(ForwardBE));
	
endmodule
