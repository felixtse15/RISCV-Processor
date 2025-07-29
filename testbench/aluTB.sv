module aluTB();
	parameter WIDTH = 4;
	logic clk, reset;
	logic [3:0] control;
	logic signed [WIDTH - 1:0] a, b;
	bit zero, sign;
	logic signed [WIDTH - 1:0] result_act, result_exp;
	
	logic [WIDTH - 1:0] controlvectors[100:0];
	logic [(WIDTH*2) - 1:0] abvectors[100:0];
	logic [WIDTH - 1:0] resultexpvectors[100:0];
	int vectornum, errors;
	
	alu dut(control, a, b, zero, sign, result_act);
	
	// Set up clock
	always begin
		clk = 1;
		#5
		clk = 0;
		#5;
	end
	// Pulse reset and load test vectors
	initial begin
		$readmemb("controlvectors.txt", controlvectors);
		$readmemb("abvectors.txt", abvectors);
		$readmemb("resultexpvectors.txt", resultexpvectors);
		vectornum = 0;
		errors = 0;
		reset = 1; #10; reset = 0;
	end
	
	always @ (posedge clk) begin
		#1;
		{control} = controlvectors[vectornum];
		{a, b} = abvectors[vectornum];
		{result_exp} = resultexpvectors[vectornum];
	end
	
	always @ (negedge clk)
		if(~reset) begin
			if (result_act != result_exp) begin
				$display("outputs = %b (%b expected)", result_act, result_exp);
				errors = errors + 1;
			end
			vectornum = vectornum + 1;
			if (abvectors[vectornum] === {WIDTH{1'bx}}) begin
				$display("%d tests completed with %d errors", vectornum, errors);
				$finish;
			end
		end		
endmodule 
																																																
