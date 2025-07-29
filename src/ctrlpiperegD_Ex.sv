module ctrlpiperegD_Ex(input  logic       clk, reset,
					   input  logic       clear,
					   input  logic [1:0] ResultSrcD,
					   input  logic       RegWriteD, MemWriteD, JumpD, BranchD,
					   input  logic [3:0] ALUControlD,
					   input  logic 	  ALUSrcAD,
					   input  logic [1:0] ALUSrcBD,
					   input  logic 	  PCJumpSrcD,
					   input  logic [2:0] funct3D,
					   output logic [1:0] ResultSrcE,
					   output logic 	  RegWriteE, MemWriteE, JumpE, BranchE,
					   output logic [3:0] ALUControlE,
					   output logic 	  ALUSrcAE,
					   output logic [1:0] ALUSrcBE,
					   output logic 	  PCJumpSrcE,
					   output logic [2:0] funct3E);
					   
	always_ff @ (posedge clk or posedge reset)
		if (reset) begin
			ResultSrcE  <= 0;
			RegWriteE   <= 0;
			MemWriteE   <= 0;
			JumpE       <= 0;
			BranchE     <= 0;
			ALUControlE <= 0;
			ALUSrcAE    <= 0;
			ALUSrcBE    <= 0;
			PCJumpSrcE  <= 0;
			funct3E		<= 0;
		end 
		else if (clear) begin
			ResultSrcE  <= 0;
			RegWriteE   <= 0;
			MemWriteE   <= 0;
			JumpE       <= 0;
			BranchE     <= 0;
			ALUControlE <= 0;
			ALUSrcAE    <= 0;
			ALUSrcBE    <= 0;
			PCJumpSrcE  <= 0;
			funct3E		<= 0;
		end
		else begin
			ResultSrcE  <= ResultSrcD;
			RegWriteE   <= RegWriteD;
			MemWriteE   <= MemWriteD;
			JumpE       <= JumpD;
			BranchE     <= BranchD;
			ALUControlE <= ALUControlD;
			ALUSrcAE    <= ALUSrcAD;
			ALUSrcBE    <= ALUSrcBD;
			PCJumpSrcE  <= PCJumpSrcD;
			funct3E		<= funct3D;
		end
		
endmodule