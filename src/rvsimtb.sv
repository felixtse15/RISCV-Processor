module rvsimtb();

	logic clk;
	logic reset;
	logic [31:0] WriteDataM, ALUResultM;
	logic MemWriteM;

	// instantiate device to be tested
	top dut(.clk(clk), .reset(reset), .WriteDataM(WriteDataM), .ALUResultM(ALUResultM), .MemWriteM(MemWriteM));
	
	// initialize test, pulse reset
	initial begin
		$display("Test started");
		reset <= 1;
	       	#8;
	       	reset <= 0;
	end

	// generate clock to sequence tests
	always begin
		clk <= 1;
		#5;
		clk <= 0;
		#5;
	end
	
	// automatically check output
	always @(negedge clk) begin
		if(MemWriteM && (ALUResultM === 76)) begin
			if(WriteDataM === 49) begin
				$display("Simulation succeeded");
				$stop;
			end else begin
				$display("Simulation failed");
				$stop;
			end
		end
	end
	
endmodule




