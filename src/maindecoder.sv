module maindecoder(input  logic [6:0] opcode,
				   output logic [1:0] ResultSrcD,
				   output logic [2:0] ImmSrcD,
				   output logic [1:0] ALUOp,
				   output logic       RegWriteD, MemWriteD,
				   output logic       JumpD, BranchD,
				   output logic       ALUSrcAD, 
				   output logic [1:0] ALUSrcBD);
	
	logic [13:0] controlbits;
	
	assign {RegWriteD, ImmSrcD, ALUSrcAD, ALUSrcBD, MemWriteD, ResultSrcD, BranchD, JumpD, ALUOp} = controlbits;

	always_comb
		case(opcode)
			7'b0000011: controlbits = 14'b1_000_0_01_0_01_0_0_00; // lw
			7'b0100011: controlbits = 14'b0_001_0_01_1_xx_0_0_00; // sw
			7'b0110011: controlbits = 14'b1_xxx_0_00_0_00_0_0_10; // R-type
			7'b1100011: controlbits = 14'b0_010_0_00_0_xx_1_0_01; // B-type
			7'b0010011: controlbits = 14'b1_000_0_01_0_00_0_0_10; // I-type 
			7'b0110111: controlbits = 14'b1_100_1_01_0_00_0_0_00; // lui
			7'b0010111: controlbits = 14'b1_100_1_10_0_00_0_0_00; // auipc
			7'b1100111: controlbits = 14'b1_000_0_01_0_10_0_1_00; // jalr
			7'b1101111: controlbits = 14'b1_011_x_xx_0_10_0_1_00; // jal
			7'b0000000: controlbits = 14'b0_000_0_00_0_00_0_0_00; // reset
			default:    controlbits = 14'bx_xxx_x_xx_x_xx_x_x_xx; // instruction not implemented
		endcase
		
endmodule