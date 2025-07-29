module datapath(input  logic        clk, reset,
				input  logic [1:0]  ResultSrcW,
				input  logic        PCJumpSrcE, PCSrcE,
				input  logic        ALUSrcAE,
				input  logic [1:0]  ALUSrcBE,
				input  logic        RegWriteW,
				input  logic [2:0]  ImmSrcD,
				input  logic [3:0]  ALUControlE,
				input  logic [31:0] InstrF,
				input  logic [31:0] ReadDataM,
				input  logic [1:0]  ForwardAE, ForwardBE,
				input  logic        StallD, StallF, FlushD, FlushE,
				output logic [4:0]  Rs1D, Rs2D, Rs1E, Rs2E,
				output logic [4:0]  RdE, RdM, RdW,
				output logic [31:0] InstrD,
				output logic        ZEROE, SIGNE,
				output logic [31:0] PCF,
				output logic [31:0] ALUResultM, WriteDataM);
				
	logic [31:0] PCD, PCE;
	logic [31:0] ALUResultE, ALUResultW;
	logic [31:0] AluAE, AluBE;
	logic [31:0] WriteDataE;
	logic [31:0] ReadDataW;
	logic [31:0] PCNextF, PCPlus4F, PCPlus4D, PCPlus4E, PCPlus4M, PCPlus4W, PCTargetE, BranchJumpTargetE;
	logic [31:0] ImmExtD, ImmExtE;
	logic [31:0] fwdSrcAE;
	logic [31:0] ResultW;
	logic [31:0] RD1D, RD2D, RD1E, RD2E;
	logic [4:0]  RdD;
	
	// FETCH STAGE
	// PC jump mux 
	mux2 pcjumpmux(.s(PCJumpSrcE), .d0(PCTargetE), .d1(ALUResultE), 
				   .y(BranchJumpTargetE));
	// PC Src mux
	mux2 pcsrcmux(.s(PCSrcE), .d0(PCPlus4F), .d1(BranchJumpTargetE), 
				  .y(PCNextF));
	// Program Counter (PC pipeline register)
	programcounter PC(.clk(clk), .reset(reset), .en(~StallF), .d(PCNextF), 
			   .q(PCF));
	// PC plus 4 adder
	adder pcadd4(.a(PCF), .b(32'd4), 
				 .y(PCPlus4F));
	
	
	// DECODE STAGE
	// pipeline register
	piperegF_D pipregFD(.clk(clk), .reset(reset), .en(~StallD), .clear(FlushD), .InstrF(InstrF), .PCF(PCF), .PCPlus4F(PCPlus4F), 
					    .InstrD(InstrD), .PCD(PCD), .PCPlus4D(PCPlus4D));
	
	
	// assign Rs1D, Rs2D, and RdD depending on the type of instruction 
	always_comb	begin
		case(InstrD[6:0])
			51: begin															// R-type instructions
				Rs1D = InstrD[19:15];
				Rs2D = InstrD[24:20];
				RdD  = InstrD[11:7];
			end
		
			3, 19, 103: begin														// I-type instructions
				Rs1D = InstrD[19:15];
				Rs2D = 5'bxxxxx;
				RdD  = InstrD[11:7];
			end
	
			35, 99: begin														// S/B-type instructions
				Rs1D = InstrD[19:15];
				Rs2D = InstrD[24:20];
				RdD  = 5'bxxxxx;
			end
		
			23, 55, 111: begin													// auipc, lui, jal
				Rs1D = 5'bxxxxx;
				Rs2D = 5'bxxxxx;
				RdD  = InstrD[11:7];
			end
		
	
			default: begin
				Rs1D = 5'bxxxxx;
				Rs2D = 5'bxxxxx;
				RdD  = 5'bxxxxx;
			end
		endcase
	end
	
	// register file
	registerfile regfile(.clk(clk), .reset(reset), .RegWrite(RegWriteW), .Rs1(Rs1D), .Rs2(Rs2D), .RdW(RdW), .WD(ResultW), 
						 .RD1(RD1D), .RD2(RD2D));
	// extend unit
	extendunit extend(.ImmSrc(ImmSrcD), .Instr(InstrD[31:7]), .ImmExt(ImmExtD));
	
	
	// EXECUTE STAGE
	// pipeline register
	piperegD_Ex pipregDEx(.clk(clk), .reset(reset), .clear(FlushE), .RD1D(RD1D), .RD2D(RD2D), .PCD(PCD), .Rs1D(Rs1D), .Rs2D(Rs2D), .ImmExtD(ImmExtD), .RdD(RdD), .PCPlus4D(PCPlus4D),
					      .RD1E(RD1E), .RD2E(RD2E), .PCE(PCE), .Rs1E(Rs1E), .Rs2E(Rs2E), .ImmExtE(ImmExtE), .RdE(RdE), .PCPlus4E(PCPlus4E));
	// ForwardmuxA
	mux3 fwdAmux(.s(ForwardAE), .d0(RD1E), .d1(ResultW), .d2(ALUResultM),
				 .y(fwdSrcAE));
	// ForwardmuxB
	mux3 fwdBmux(.s(ForwardBE), .d0(RD2E), .d1(ResultW), .d2(ALUResultM), 
				 .y(WriteDataE));
	// ALUSrcAMux
	mux2 ALUSrcAmux(.s(ALUSrcAE), .d0(fwdSrcAE), .d1(32'b0),
					.y(AluAE));
	// ALUSrcBMux
	mux3 ALUSrcBmux(.s(ALUSrcBE), .d0(WriteDataE), .d1(ImmExtE), .d2(PCTargetE),
					.y(AluBE));
	// PCTargetadder
	adder PCTargetadd(.a(PCE), .b(ImmExtE),
					  .y(PCTargetE));
	// ALU
	alu alu(.ALUControl(ALUControlE), .AluA(AluAE), .AluB(AluBE),
			.ZERO(ZEROE), .SIGN(SIGNE), .ALUResult(ALUResultE));
			
	
	// MEMORY STAGE
	// pipeline register
	piperegEx_M pipregExM(.clk(clk), .reset(reset), .ALUResultE(ALUResultE), .WriteDataE(WriteDataE), .RdE(RdE), .PCPlus4E(PCPlus4E),
						  .ALUResultM(ALUResultM), .WriteDataM(WriteDataM), .RdM(RdM), .PCPlus4M(PCPlus4M));
						
	// WRITEBACK STAGE
	// pipeline register
	piperegM_W pipregMW(.clk(clk), .reset(reset), .ALUResultM(ALUResultM), .ReadDataM(ReadDataM), .RdM(RdM), .PCPlus4M(PCPlus4M),
					    .ALUResultW(ALUResultW), .ReadDataW(ReadDataW), .RdW(RdW), .PCPlus4W(PCPlus4W));
	// Result mux
	mux3 resultmux(.s(ResultSrcW), .d0(ALUResultW), .d1(ReadDataW), .d2(PCPlus4W),
				   .y(ResultW));
				   
endmodule




//ReadDataM, ForwardAE, ForwardBE, Rs1D, Rs2D, 
//Rs1E, Rs2E, RdE, RdM, RdW, StallD, StallF, FlushD, FlushE);
	