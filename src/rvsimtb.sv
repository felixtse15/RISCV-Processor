/* Copyright 2025 Felix Tse

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0
*/
module rvsimtb();

	logic clk;
	logic reset;
	logic cycles;
	logic [31:0] WriteDataM, ALUResultM;
	logic MemWriteM;

	// instantiate device to be tested
	top dut(.clk(clk), .reset(reset), .WriteDataM(WriteDataM), .ALUResultM(ALUResultM), .MemWriteM(MemWriteM));
	
	// initialize test, pulse reset
	initial begin
		$display("Test started");
		cycles <= 0;
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
	
	always @(posedge clk)
		cycles <= cycles + 1;
	
	// automatically check output
	always @(negedge clk) begin
		if(MemWriteM && (ALUResultM === 212) && cycles < 500) begin
			if(WriteDataM === 511) begin
				$display("Simulation succeeded");
				$stop;
			end else begin
				$display("Simulation failed");
				$stop;
			end
		end else if (cycles >= 500) begin
			$display("Simulation failed");
			$stop;
		end
	end
	
endmodule




