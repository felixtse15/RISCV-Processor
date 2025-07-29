  module controller(input  logic 	   clk, reset,
				    input  logic [6:0] opcode,
				    input  logic [2:0] funct3,
				    input  logic       funct7b5,
				    input  logic       ZEROE, SIGNE,
				    input  logic       FlushE,
				    output logic       ResultSrcE0,
				    output logic [1:0] ResultSrcW,
				    output logic       MemWriteM,
				    output logic       PCJumpSrcD, PCJumpSrcE, PCSrcE,
				    output logic       ALUSrcAE, 
				    output logic [1:0] ALUSrcBE,
				    output logic       RegWriteE, RegWriteM, RegWriteW,
				    output logic [2:0] ImmSrcD,
				    output logic [3:0] ALUControlE);

	logic [1:0] ALUOp;
	logic       RegWriteD, MemWriteD, JumpD, BranchD;
	logic       MemWriteE, JumpE, BranchE;
	logic [1:0] ResultSrcD, ResultSrcE, ResultSrcM;
	logic [3:0] ALUControlD;
	logic       ALUSrcAD; 
	logic [1:0] ALUSrcBD;
	logic [2:0] funct3E;
	logic       ZeroR, SignR, BranchR; // Control signal outputs from XOR and mux for branch prediction
	
		
	assign ResultSrcE0 = ResultSrcE[0];
	
	maindecoder maindec(.opcode(opcode), 
						.ResultSrcD(ResultSrcD), .ImmSrcD(ImmSrcD), .ALUOp(ALUOp), .RegWriteD(RegWriteD), .MemWriteD(MemWriteD), .JumpD(JumpD), .BranchD(BranchD), .ALUSrcAD(ALUSrcAD), .ALUSrcBD(ALUSrcBD));
	
	aludecoder aludec(.opcodeb5(opcode[5]), .funct3(funct3), .funct7b5(funct7b5), .ALUOp(ALUOp), 
					  .ALUControlD(ALUControlD));
	
	ctrlpiperegD_Ex cpipregDEx(.clk(clk), .reset(reset), .clear(FlushE), .ResultSrcD(ResultSrcD), .RegWriteD(RegWriteD), .MemWriteD(MemWriteD), .JumpD(JumpD), .BranchD(BranchD), .ALUControlD(ALUControlD), .ALUSrcAD(ALUSrcAD), .ALUSrcBD(ALUSrcBD), .PCJumpSrcD(PCJumpSrcD), .funct3D(funct3),
							   .ResultSrcE(ResultSrcE), .RegWriteE(RegWriteE), .MemWriteE(MemWriteE), .JumpE(JumpE), .BranchE(BranchE), .ALUControlE(ALUControlE), .ALUSrcAE(ALUSrcAE), .ALUSrcBE(ALUSrcBE), .PCJumpSrcE(PCJumpSrcE), .funct3E(funct3E));
			
	ctrlpiperegEx_M cpipregExM(.clk(clk), .reset(reset), .RegWriteE(RegWriteE), .ResultSrcE(ResultSrcE), .MemWriteE(MemWriteE),
							   .RegWriteM(RegWriteM), .ResultSrcM(ResultSrcM), .MemWriteM(MemWriteM));
	
	ctrlpiperegM_W cpipregMW(.clk(clk), .reset(reset), .RegWriteM(RegWriteM), .ResultSrcM(ResultSrcM),
							 .RegWriteW(RegWriteW), .ResultSrcW(ResultSrcW));
	
	// Branch decision logic 
	always_comb begin
		if (~reset) begin
			ZeroR      = funct3E[0] ^ ZEROE;
			SignR      = funct3E[0] ^ SIGNE;
			BranchR    = funct3E[2] ? (SignR) : (ZeroR);
			PCSrcE     = (BranchR & BranchE) | JumpE;
			PCJumpSrcD = (opcode == 7'b1100111) ? 1 : 0;
		end else begin
			ZeroR      = 0;
			SignR      = 0;
			BranchR    = 0;
			PCSrcE     = 0;
			PCJumpSrcD = 0;
		end
	end
endmodule
	
	
	
	

