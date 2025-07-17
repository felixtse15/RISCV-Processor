module piperegF_D(input  logic 		  clk, reset,
				  input  logic 		  en, clear,
				  input  logic [31:0] InstrF,
				  input  logic [31:0] PCF, PCPlus4F,
				  output logic [31:0] InstrD,
				  output logic [31:0] PCD, PCPlus4D);
	
	always_ff @ (posedge clk or posedge reset) begin
		if (reset) begin // asynchronous clear
			InstrD   <= 0;
			PCD 	 <= 0;
			PCPlus4D <= 0;
		end 
		else if (clear) begin
			InstrD   <= 0;
			PCD 	 <= 0;
			PCPlus4D <= 0;
		end 
		else if (en) begin
			InstrD   <= InstrF;
			PCD	     <= PCF;
			PCPlus4D <= PCPlus4F;
		end
	end	
	
endmodule