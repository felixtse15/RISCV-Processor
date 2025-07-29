module ctrlpiperegM_W(input  logic 		 clk, reset,
					  input  logic 		 RegWriteM,
					  input  logic [1:0] ResultSrcM,
					  output logic 		 RegWriteW,
					  output logic [1:0] ResultSrcW);
	
	always_ff @ (posedge clk or posedge reset) begin
		if (reset) begin
			RegWriteW  <= 0;
			ResultSrcW <= 0;
		end
		else begin
			RegWriteW  <= RegWriteM;
			ResultSrcW <= ResultSrcM;
		end
	end
	
endmodule