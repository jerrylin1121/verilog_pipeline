`define IDISK "./iimage.bin"
`define DDISK "./dimage.bin"
`define CYC 30
`define ENDCYCLE 50000000

module tb;

	parameter DISK_SIZE = 1024;
	parameter NUM_REG = 35;

	reg [31:0] i_disk [0:DISK_SIZE-1];
	reg [31:0] d_disk [0:DISK_SIZE-1];
	integer ifile, dfile, r;
	integer snapfile, errorfile;

	reg [31:0] register[0:NUM_REG-1];
	wire [33:0] print_reg;
	wire [31:0] _PC, _HI, _LO;
	wire [4:0] RA, RB;
	reg [31:0] A, B;
	wire RWen;
	wire [4:0]RWAddr;
	wire [31:0]RWdata;

	wire [31:0] IF_ins, ID_ins, EX_ins, DM_ins, WB_ins;
	wire Wen, Finish;
	wire [1:0]WSize;
	wire [9:0] RAddr_i, RAddr_d, WAddr_d;
	reg [31:0] Rdata_i, Rdata_d;
	wire [31:0] Wdata_d;

	reg clk, rst;
	reg [19:0]cycle;

	wire stalled, flush, write_0, HI_LO_overwrite;
	wire [2:0]rs, rt;
	wire [4:0] EX_DM_to_ID_reg;
	wire [4:0] EX_DM_to_EX_reg;
	wire [4:0] DM_WB_to_EX_reg;

	pipeline pl(
		.clk(clk),
		.rst(rst),
		.IF_ins(IF_ins),
		.ID_ins(ID_ins),
		.EX_ins(EX_ins),
		.DM_ins(DM_ins),
		.WB_ins(WB_ins),
		.HI(register[32]),
		.LO(register[33]),
		.PC(register[34]),
		.Rdata_i(Rdata_i),
		.RAddr_d(RAddr_d),
		.Rdata_d(Rdata_d),
		.Wen(Wen),
		.WSize(WSize),
		.WAddr_d(WAddr_d),
		.Wdata_d(Wdata_d),
		._HI(_HI),
		._LO(_LO),
		._PC(_PC),
		.RA(RA),
		.RB(RB),
		.A(A),
		.B(B),
		.Finish(Finish),
		.RWen(RWen),
		.RWAddr(RWAddr),
		.RWdata(RWdata),
		.print_reg(print_reg),
		.stalled(stalled),
		.flush(flush),
		.rs(rs),
		.rt(rt),
		.EX_DM_to_ID_reg(EX_DM_to_ID_reg),
		.EX_DM_to_EX_reg(EX_DM_to_EX_reg),
		.DM_WB_to_EX_reg(DM_WB_to_EX_reg),
		.write_0(write_0),
		.HI_LO_overwrite(HI_LO_overwrite));

	always #(`CYC/2) clk = ~clk;

/*	initial begin
		$fsdbDumpfile("pipeline.fsdb");
		$fsdbDumpvars;
	end
*/
	initial begin
		clk = 1'b1;
		rst = 1'b1;
		cycle = 20'b1111_1111_1111_1111_1110;
		#(5); rst = 1'b0;
	end

	always@(negedge clk)begin
		Rdata_i <= i_disk[register[34]>>2];
	end

	always@(negedge clk)begin
		Rdata_d <= d_disk[RAddr_d>>2];
	end

	reg prev_dif, dif;

	always@(posedge clk)begin
		prev_dif <= dif;
	end

	reg print_HI, print_LO;

	always@(negedge clk)begin
		if(register[32]!=_HI)begin
			print_HI <= 1'b1;
			register[32] <= _HI;
		end else begin
			print_HI <= 1'b0;
		end
		if(register[33]!=_LO)begin
			print_LO <= 1'b1;
			register[33] <= _LO;
		end else begin
			print_LO <= 1'b0;
		end
	end	

	always@(posedge clk)begin
		if(write_0)begin
			$fwrite(errorfile, "In cycle %0d: Write $0 error\n", cycle);
		end
		if(HI_LO_overwrite)begin
			$fwrite(errorfile, "In cycle %0d: Overwrite HI-LO registers\n", cycle);
		end
	end

	always@(negedge clk)begin
		dif <= 1'b0;
		if(RWen && RWAddr!=0)begin
			if(register[RWAddr]!=RWdata)begin
				dif <= 1'b1;
				register[RWAddr] <= RWdata;
			end else begin
				dif <= 1'b0;
			end
		end
		#5;
		A = register[RA];
		B = register[RB];
	end

	initial begin
		snapfile = $fopen("snapshot.rpt", "w");
		errorfile = $fopen("error_dump.rpt", "w");
	end

	reg [10:0] i, num;
	reg [31:0] in;
	initial begin
		//Initial disk
		i = 0;
		repeat(34)begin
			i_disk[i] = 0;
			d_disk[i] = 0;
			register[i] = 0;
			i = i + 1;
		end
		repeat(990)begin
			i_disk[i] = 0;
			d_disk[i] = 0;
			i = i + 1;
		end

		//Read data from iimage.bin
		ifile = $fopen(`IDISK, "rb");
		r = $fread(in, ifile);
		register[34] = in;
		i = 0;
		r = $fread(in, ifile);
		num = in;
		$display(num);
		i = 0;
		repeat(num)begin
			r = $fread(in, ifile);
			i_disk[(register[34]>>2)+i] = in;
			i_disk[(register[34]>>2)+i] = in;
			$display("0x%h", i_disk[(register[34]>>2)+i]);
			i = i + 1;
		end
		$fclose(ifile);

		//Read data from dimage.bin
		dfile = $fopen(`DDISK, "rb");
		r = $fread(in, dfile);
		register[29] = in;
		i = 0;
		r = $fread(in, dfile);
		num = in;
		$display(num);
		i = 0;
		repeat(num)begin
			r = $fread(in, dfile);
			d_disk[i] = in;
			d_disk[i] = in;
			$display("0x%h", d_disk[i]);
			i = i + 1;
		end
		$fclose(dfile);
	end

	wire [31:0] pc = register[34] - 4;

	//print output to file
	always@(negedge clk)begin
		if(~cycle[19])begin
			$fwrite(snapfile, "cycle %0d\n", cycle);
			if(!(|cycle))begin
				i = 0;
				repeat(32)begin
					$fwrite(snapfile, "$%02d: 0x%08h\n", i, register[i]);
					i = i + 1;
				end
				$fwrite(snapfile, "$HI: 0x%08h\n", register[32]);
				$fwrite(snapfile, "$LO: 0x%08h\n", register[33]);
			end
			i = 0;
			repeat(32)begin
				if(print_reg[i] & prev_dif)
					$fwrite(snapfile, "$%02d: 0x%08h\n", i, register[i]);
				i = i + 1;
			end
			if(print_HI)
				$fwrite(snapfile, "$HI: 0x%08h\n", register[32]);
			if(print_LO)
				$fwrite(snapfile, "$LO: 0x%08h\n", register[33]);
			$fwrite(snapfile, "PC: 0x%08h\n", pc);
			$fwrite(snapfile, "IF: 0x%08h", IF_ins);
			if(stalled)
				$fwrite(snapfile, " to_be_stalled");
			if(flush)
				$fwrite(snapfile, " to_be_flushed");
			$fwrite(snapfile, "\nID: ");
			print_ins(ID_ins[31:26], ID_ins[5:0], ~((&ID_ins[31:26]) & (&ID_ins[20:0])));
			if(stalled)
				$fwrite(snapfile, " to_be_stalled");
			if(rs[0])
				$fwrite(snapfile, " fwd_EX-DM_rs_$%0d", EX_DM_to_ID_reg);
			if(rt[0])
				$fwrite(snapfile, " fwd_EX-DM_rt_$%0d", EX_DM_to_ID_reg);
			$fwrite(snapfile, "\nEX: ");
			print_ins(EX_ins[31:26], EX_ins[5:0], ~((&EX_ins[31:26]) & (&EX_ins[20:0])));
			if(rs[1])
				$fwrite(snapfile, " fwd_EX-DM_rs_$%0d", EX_DM_to_EX_reg);
			if(rs[2])
				$fwrite(snapfile, " fwd_DM-WB_rs_$%0d", DM_WB_to_EX_reg);
			if(rt[1])
				$fwrite(snapfile, " fwd_EX-DM_rt_$%0d", EX_DM_to_EX_reg);
			if(rt[2])
				$fwrite(snapfile, " fwd_DM-WB_rt_$%0d", DM_WB_to_EX_reg);
			$fwrite(snapfile, "\nDM: ");
			print_ins(DM_ins[31:26], DM_ins[5:0], ~((&DM_ins[31:26]) & (&DM_ins[20:0])));
			$fwrite(snapfile, "\nWB: ");
			print_ins(WB_ins[31:26], WB_ins[5:0], ~((&WB_ins[31:26]) & (&WB_ins[20:0])));
			$fwrite(snapfile, "\n\n\n");
		end
		cycle = cycle+1;
		register[34] = _PC;
	end

	always@(posedge Finish)begin
		$finish;
	end
	
	initial begin
		#`ENDCYCLE;
		$finish;
	end

	// print Instruction
	task print_ins;
		input [5:0] opcode, funct;
		input is_NOP;

		case(opcode)

			6'h00:begin
				
				case(funct)
					
					6'h20:begin
						$fwrite(snapfile, "ADD");
					end
					6'h21:begin
						$fwrite(snapfile, "ADDU");
					end
					6'h22:begin
						$fwrite(snapfile, "SUB");
					end
					6'h24:begin
						$fwrite(snapfile, "AND");
					end
					6'h25:begin
						$fwrite(snapfile, "OR");
					end
					6'h26:begin
						$fwrite(snapfile, "XOR");
					end
					6'h27:begin
						$fwrite(snapfile, "NOR");
					end
					6'h28:begin
						$fwrite(snapfile, "NAND");
					end
					6'h2a:begin
						$fwrite(snapfile, "SLT");
					end
					6'h00:begin
						if(is_NOP)
							$fwrite(snapfile, "NOP");
						else
							$fwrite(snapfile, "SLL");
					end
					6'h02:begin
						$fwrite(snapfile, "SRL");
					end
					6'h03:begin
						$fwrite(snapfile, "SRA");
					end
					6'h08:begin
						$fwrite(snapfile, "JR");
					end
					6'h18:begin
						$fwrite(snapfile, "MULT");
					end
					6'h19:begin
						$fwrite(snapfile, "MULTU");
					end
					6'h10:begin
						$fwrite(snapfile, "MFHI");
					end
					6'h12:begin
						$fwrite(snapfile, "MFLO");
					end

				endcase

			end
			6'h08:begin
				$fwrite(snapfile, "ADDI");
			end
			6'h09:begin
				$fwrite(snapfile, "ADDIU");
			end
			6'h23:begin
				$fwrite(snapfile, "LW");
			end
			6'h21:begin
				$fwrite(snapfile, "LH");
			end
			6'h25:begin
				$fwrite(snapfile, "LHU");
			end
			6'h20:begin
				$fwrite(snapfile, "LB");
			end
			6'h24:begin
				$fwrite(snapfile, "LBU");
			end
			6'h2b:begin
				$fwrite(snapfile, "SW");
			end
			6'h29:begin
				$fwrite(snapfile, "SH");
			end
			6'h28:begin
				$fwrite(snapfile, "SB");
			end
			6'h0f:begin
				$fwrite(snapfile, "LUI");
			end
			6'h0c:begin
				$fwrite(snapfile, "ANDI");
			end
			6'h0d:begin
				$fwrite(snapfile, "ORI");
			end
			6'h0e:begin
				$fwrite(snapfile, "NORI");
			end
			6'h0a:begin
				$fwrite(snapfile, "SLTI");
			end
			6'h04:begin
				$fwrite(snapfile, "BEQ");
			end
			6'h05:begin
				$fwrite(snapfile, "BNE");
			end
			6'h07:begin
				$fwrite(snapfile, "BGTZ");
			end
			6'h02:begin
				$fwrite(snapfile, "J");
			end
			6'h03:begin
				$fwrite(snapfile, "JAL");
			end
			6'h3f:begin
				$fwrite(snapfile, "HALT");
			end

		endcase

	endtask

endmodule
