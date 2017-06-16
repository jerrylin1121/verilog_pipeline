`define IDISK "./iimage.bin"
`define DDISK "./dimage.bin"
`define CYC 30

module tb;

	parameter DISK_SIZE = 1024;
	parameter NUM_REG = 32;

	reg [31:0] i_disk [0:DISK_SIZE-1];
	reg [31:0] d_disk [0:DISK_SIZE-1];
	integer ifile, dfile, r;
	integer snapfile, errorfile;

	reg [31:0] register[0:NUM_REG-1];
	reg [31:0] HI, LO, PC;
	wire [31:0] _PC;
	wire [31:0] IF_ins, ID_ins, EX_ins, DM_ins, WB_ins;
	wire Wen, Finish;
	wire [9:0] RAddr_i, RAddr_d, WAddr_d;
	reg [31:0] Rdata_i, Rdata_d;
	wire [31:0] Wdata_d;

	reg clk, rst;

	pipeline pl(
		.clk(clk),
		.rst(rst),
		.IF_ins(IF_ins),
		.ID_ins(ID_ins),
		.EX_ins(EX_ins),
		.DM_ins(DM_ins),
		.WB_ins(WB_ins),
		.PC(PC),
		.RAddr_i(RAddr_i),
		.Rdata_i(Rdata_i),
		.RAddr_d(RAddr_d),
		.Rdata_d(Rdata_d),
		.Wen(Wen),
		.WAddr_d(WAddr_d),
		.Wdata_d(Wdata_d),
		._PC(_PC),
		.Finish(Finish));

	always #(`CYC/2) clk = ~clk;

	initial begin
		clk = 1'b0;
		rst = 1'b0;
		@(negedge clk) rst = 1'b1;
		#(`CYC); rst = 1'b0;
	end

	always@(posedge clk)begin
		Rdata_i = i_disk[RAddr_i>>2];
		$fwrite(errorfile, "%h, %h\n", RAddr_i, Rdata_i);
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
		HI = 0;
		LO = 0;
		repeat(32)begin
			i_disk[i] = 0;
			d_disk[i] = 0;
			register[i] = 0;
			i = i + 1;
		end
		repeat(992)begin
			i_disk[i] = 0;
			d_disk[i] = 0;
			i = i + 1;
		end

		//Read data from iimage.bin
		ifile = $fopen(`IDISK, "rb");
		r = $fread(in, ifile);
		PC = in;
		i = 0;
		r = $fread(in, ifile);
		num = in;
		$display(num);
		i = 0;
		repeat(num)begin
			r = $fread(in, ifile);
			i_disk[(PC>>2)+i] = in;
			i_disk[(PC>>2)+i] = in;
			$display("0x%h", i_disk[(PC>>2)+i]);
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

	//print output to file
	initial begin
		$fwrite(snapfile, "cycle 0\n");
		i = 0;
		repeat(32)begin
			$fwrite(snapfile, "$%02d: 0x%h\n", i, register[i]);
			i = i + 1;
		end
		$fwrite(snapfile, "$HI: 0x%h\n", HI);
		$fwrite(snapfile, "$LO: 0x%h\n", LO);
		$fwrite(snapfile, "PC: 0x%h\n", PC);
		$fwrite(snapfile, "IF: ");
		$fwrite(snapfile, "ID: ");
		$fwrite(snapfile, "EX: ");
		$fwrite(snapfile, "DM: ");
		$fwrite(snapfile, "WB: ");
	end

	always@(posedge clk)begin
		$fwrite(snapfile, "PC: 0x%h\n", _PC);
		$fwrite(snapfile, "IF: ");
		print_ins(IF_ins[31:26], IF_ins[5:0], ~((&IF_ins[31:26]) & (&IF_ins[20:0])));
		$fwrite(snapfile, "\nID: ");
		print_ins(ID_ins[31:26], ID_ins[5:0], ~((&ID_ins[31:26]) & (&ID_ins[20:0])));
		$fwrite(snapfile, "\nEX: ");
		print_ins(EX_ins[31:26], EX_ins[5:0], ~((&EX_ins[31:26]) & (&EX_ins[20:0])));
		$fwrite(snapfile, "\nDM: ");
		print_ins(DM_ins[31:26], DM_ins[5:0], ~((&DM_ins[31:26]) & (&DM_ins[20:0])));
		$fwrite(snapfile, "\nWB: ");
		print_ins(WB_ins[31:26], WB_ins[5:0], ~((&WB_ins[31:26]) & (&IF_ins[20:0])));
		$fwrite(snapfile, "\n\n");
	end

	always@(posedge Finish)begin
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
