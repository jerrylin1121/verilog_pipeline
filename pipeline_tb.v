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

	reg clk, rst;

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
		$fwrite(snapfile, "ID: ");
		print_ins(6'h08, 6'h00);
	end

	task print_ins;
		input [5:0] opcode, funct;
		input is_NOP;

		case(opcode)

			6'h00:begin
				
				case(funct)
					
					6'h20:begin
						$fwrite(snapfile, "ADD\n");
					end
					6'h21:begin
						$fwrite(snapfile, "ADDU\n");
					end
					6'h22:begin
						$fwrite(snapfile, "SUB\n");
					end
					6'h24:begin
						$fwrite(snapfile, "AND\n");
					end
					6'h25:begin
						$fwrite(snapfile, "OR\n");
					end
					6'h26:begin
						$fwrite(snapfile, "XOR\n");
					end
					6'h27:begin
						$fwrite(snapfile, "NOR\n");
					end
					6'h28:begin
						$fwrite(snapfile, "NAND\n");
					end
					6'h2a:begin
						$fwrite(snapfile, "SLT\n");
					end
					6'h00:begin
						if(is_NOP)
							$fwrite(snapfile, "NOP\n");
						else
							$fwrite(snapfile, "SLL\n");
					end
					6'h02:begin
						$fwrite(snapfile, "SRL\n");
					end
					6'h03:begin
						$fwrite(snapfile, "SRA\n");
					end
					6'h08:begin
						$fwrite(snapfile, "JR\n");
					end
					6'h18:begin
						$fwrite(snapfile, "MULT\n");
					end
					6'h19:begin
						$fwrite(snapfile, "MULTU\n");
					end
					6'h10:begin
						$fwrite(snapfile, "MFHI\n");
					end
					6'h12:begin
						$fwrite(snapfile, "MFLO\n");
					end

				endcase

			end
			6'h08:begin
				$fwrite(snapfile, "ADDI\n");
			end
			6'h09:begin
				$fwrite(snapfile, "ADDIU\n");
			end
			6'h23:begin
				$fwrite(snapfile, "LW\n");
			end
			6'h21:begin
				$fwrite(snapfile, "LH\n");
			end
			6'h25:begin
				$fwrite(snapfile, "LHU\n");
			end
			6'h20:begin
				$fwrite(snapfile, "LB\n");
			end
			6'h24:begin
				$fwrite(snapfile, "LBU\n");
			end
			6'h2b:begin
				$fwrite(snapfile, "SW\n");
			end
			6'h29:begin
				$fwrite(snapfile, "SH\n");
			end
			6'h28:begin
				$fwrite(snapfile, "SB\n");
			end
			6'h0f:begin
				$fwrite(snapfile, "LUI\n");
			end
			6'h0c:begin
				$fwrite(snapfile, "ANDI\n");
			end
			6'h0d:begin
				$fwrite(snapfile, "ORI\n");
			end
			6'h0e:begin
				$fwrite(snapfile, "NORI\n");
			end
			6'h0a:begin
				$fwrite(snapfile, "SLTI\n");
			end
			6'h04:begin
				$fwrite(snapfile, "BEQ\n");
			end
			6'h05:begin
				$fwrite(snapfile, "BNE\n");
			end
			6'h07:begin
				$fwrite(snapfile, "BGTZ\n");
			end
			6'h02:begin
				$fwrite(snapfile, "J\n");
			end
			6'h03:begin
				$fwrite(snapfile, "JAL\n");
			end
			6'h3f:begin
				$fwrite(snapfile, "HALT\n");
			end

		endcase

	endtask

endmodule
