// hazardunit h( );
module hazardunit(input  logic [4:0] Rs1D, Rs2D, Rs1E, Rs2E, RdE, RdM, RdW,
				  input  logic 		 ResultSrcE0, RegWriteE, RegWriteM, RegWriteW,
				  input  logic       PCSrcE,
				  output logic 		 StallF, StallD, FlushD, FlushE,
				  output logic [1:0] ForwardAE, ForwardBE);
	logic lwStall;
	
	// Forwarding
	always_comb begin
	// if Rs1E or Rs2E matches either RdM or RdW, and not x0
		if (((Rs1E == RdM) && RegWriteM) && (Rs1E != 0))			// if both memory and writeback match, memory takes priority
			ForwardAE = 2'b10;									// Corresponding Rs will receive a forward signal from Hazard unit
		else if (((Rs1E == RdW) && RegWriteW) && (Rs1E != 0))
			ForwardAE = 2'b01;
		else 
			ForwardAE = 2'b00;
			
		if (((Rs2E == RdM) && RegWriteM) && (Rs2E != 0))
			ForwardBE = 2'b10;
		else if (((Rs2E == RdW) && RegWriteW) && (Rs2E != 0))
			ForwardBE = 2'b01;
		else
			ForwardBE = 2'b00;
	end	

	
	
	// Checks if lw instruction is currently in Execute stage, and if destination register matches source registers in Decode stage
	// Check if RegWrite is enabled, if not Rd will be X
	always_comb begin
		if (RegWriteE && ResultSrcE0) begin
			lwStall = (RdE inside {Rs1D, Rs2D});
		end
		else begin
			lwStall = 0;
		end
		StallF = lwStall;			// Stalls fetch stage by one cycle so data can be moved to destination register  
		StallD = lwStall;			// Stalls decode stage by one cycle so data can be moved to destination register
		FlushD = PCSrcE;							// Assume branch not taken, if taken, FlushD and FlushE
		FlushE = PCSrcE | lwStall;					// FlushE if lwStall or branch misprediction penalty	
	end

	
	
	
	
endmodule

