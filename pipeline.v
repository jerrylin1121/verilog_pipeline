module pipeline(clk, rst, ID_ins, EX_ins, DM_ins, WB_ins, PC, Rdata_i, RAddr_d, Rdata_d, Wen, WAddr_d, Wdata_d, _PC, Finish);

	input clk, rst;
	input [31:0] Rdata_i, Rdata_d;
	input [31:0] PC;
	output reg [31:0] ID_ins, EX_ins, DM_ins, WB_ins;
	output reg [9:0] RAddr_d;
	output reg Wen;
	output reg [9:0]WAddr_d;
	output reg [31:0] Wdata_d;
	output reg [31:0] _PC;
	output reg Finish;

	reg [31:0] ID_ins_next, EX_ins_next, DM_ins_next, WB_ins_next;
	reg [9:0] RAddr_d_next;
	reg Wen_next;
	reg [9:0] WAddr_d_next;
	reg [31:0] Wdata_d_next;
	reg [31:0] _PC_next;
	reg Finish_next;

	always@(posedge clk, posedge rst)begin
		if(rst)begin
			ID_ins <= 32'b0;
			EX_ins <= 32'b0;
			DM_ins <= 32'b0;
			WB_ins <= 32'b0;
			RAddr_d <= 10'b0;
			Wen <= 1'b0;
			WAddr_d <= 10'b0;
			Wdata_d <= 32'b0;
			_PC <= PC;
			Finish <= 1'b0;
		end else begin
			ID_ins <= ID_ins_next;
			EX_ins <= EX_ins_next;
			DM_ins <= DM_ins_next;
			WB_ins <= WB_ins_next;
			RAddr_d <= RAddr_d_next;
			Wen <= Wen_next;
			WAddr_d <= WAddr_d_next;
			Wdata_d <= Wdata_d_next;
			_PC <= _PC_next;
			Finish <= Finish_next;
		end
	end

	always@(*)begin
		ID_ins_next = Rdata_i;
		_PC_next = _PC+4;	
	end
	always@(*)begin
		EX_ins_next = ID_ins;
	end
	always@(*)begin
		DM_ins_next = EX_ins;
		RAddr_d_next = RAddr_d;
		Wen_next = 1'b0;
		WAddr_d_next = WAddr_d;
		Wdata_d_next = Wdata_d;
	end
	always@(*)begin
		WB_ins_next = DM_ins;
	end
	always@(*)begin
		Finish_next = (&ID_ins[31:26]) & (&EX_ins[31:26]) & (&DM_ins[31:26]) & (&WB_ins[31:26]);
	end

endmodule
