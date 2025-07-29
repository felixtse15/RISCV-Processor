module aludecoder(input  logic 		 opcodeb5,
				  input  logic [2:0] funct3,
				  input  logic 		 funct7b5,
				  input  logic [1:0] ALUOp,
				  output logic [3:0] ALUControlD);
	logic Rtype;
	assign Rtype = funct7b5 & opcodeb5;
	always_comb
		case(ALUOp)
			2'b00: ALUControlD = 4'b0000; // lw,sw addition
			2'b01: ALUControlD = 4'b0001; // beq subtract
			default: case(funct3)
				3'b000: if (Rtype)
							ALUControlD = 4'b0001; // Rtype sub
						else
							ALUControlD = 4'b0000; // add, addi
				3'b001: 	ALUControlD = 4'b0111; // sll, slli
				3'b010: 	ALUControlD = 4'b0101; // slt, slti
				3'b011: 	ALUControlD = 4'b0110; // sltu, sltiu
				3'b100: 	ALUControlD = 4'b0100; // xor, xori
				3'b101: if (funct7b5)
							ALUControlD = 4'b1001; // sra, srai
						else
							ALUControlD = 4'b1000; // srl, srli
				3'b110: 	ALUControlD = 4'b0011; // or, ori
				3'b111: 	ALUControlD = 4'b0010; // and, andi
				default:	ALUControlD = 4'bxxxx; // default case
				endcase
		endcase
		
endmodule