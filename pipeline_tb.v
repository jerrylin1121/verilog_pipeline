`define IDISK "./iimage.bin"
`define DDISK "./dimage.bin"

module tb;

	parameter DISK_SIZE = 1024;
	parameter NUM_REG = 32;

	reg [31:0] i_disk [0:DISK_SIZE-1];
	reg [31:0] d_disk [0:DISK_SIZE-1];
	integer ifile, dfile, r;
	integer snapfile, errorfile;

	reg [31:0] register[0:NUM_REG-1];
	reg [31:0] HI, LO, PC;
	wire [3*8:0] str = "NOP";


	initial begin
		snapfile = $fopen("snapshot.rpt", "w");
		errorfile = $fopen("error_dump.rpt", "w");
	end

	reg [10:0] i, num;
	reg [31:0] in;
	initial begin
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
		//Read data from iimage.bin and dimage.bin
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
		$fwrite(snapfile, "$PC: 0x%h\n", PC);
		$fwrite(snapfile, "ID:%s\n", str);
	end

endmodule
