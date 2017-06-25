module pipeline(clk, rst, IF_ins, ID_ins, EX_ins, DM_ins, WB_ins, HI, LO, PC, Rdata_i, RAddr_d, Rdata_d, Wen, WSize, WAddr_d, Wdata_d, _HI, _LO, _PC, RA, RB, A, B, Finish, RWen, RWAddr, RWdata, print_reg);

	input clk, rst;
	input [31:0] Rdata_i, Rdata_d;
	input [31:0] HI, LO, PC;
	input [31:0] A, B;
	output reg [31:0] IF_ins, ID_ins, EX_ins, DM_ins, WB_ins;
	output reg [9:0] RAddr_d;
	output reg Wen;
	output reg [1:0] WSize;
	output reg [9:0]WAddr_d;
	output reg [31:0] Wdata_d;
	output reg [31:0] _HI, _LO, _PC;
	output reg [4:0] RA, RB;
	output reg Finish;
	output reg RWen;
	output reg [4:0]RWAddr;
	output reg [31:0]RWdata;
	output reg [33:0] print_reg;

	reg [31:0] IF_ins_next, ID_ins_next, EX_ins_next, DM_ins_next, WB_ins_next;
	reg [9:0] RAddr_d_next;
	reg Wen_next;
	reg [1:0] WSize_next;
	reg [9:0] WAddr_d_next;
	reg [31:0] Wdata_d_next;
	reg [31:0] _HI_next, _LO_next,_PC_next;
	reg [4:0] RA_next, RB_next;
	reg Finish_next;
	reg RWen_next;
	reg [4:0]RWAddr_next;
	reg [31:0]RWdata_next;

	reg [3:0] reg_use[0:31];
	reg [3:0] reg_use_next[0:31];
	reg [33:0] WB_print_reg, WB_print_reg_next;
	reg [33:0] print_reg_next;

	reg signed [31:0] ID_A, ID_B, ID_A_next, ID_B_next;
	reg signed [31:0] EX_A, EX_B, EX_A_next, EX_B_next;
	reg signed [31:0] DM_B, DM_B_next;
	reg [31:0] EX_ALUOUT, EX_ALUOUT_next;
	reg [31:0] DM_ALUOUT, DM_ALUOUT_next, DM_MDR, DM_MDR_next;
	reg count;
	reg stalled, stalled_next;
	reg flush, flush_next;
	reg EX_ALUReady, EX_ALUReady_next;
	reg DM_ALUReady, DM_ALUReady_next;
	reg DM_MDRReady, DM_MDRReady_next;
	reg WB_ALUReady, WB_ALUReady_next;
	reg WB_MDRReady, WB_MDRReady_next;

	always@(posedge clk, posedge rst)begin
		if(rst | ~count)begin
			IF_ins <= 32'b0;
			ID_ins <= 32'b0;
			EX_ins <= 32'b0;
			DM_ins <= 32'b0;
			WB_ins <= 32'b0;
			RAddr_d <= 10'b0;
			Wen <= 1'b0;
			WSize <= 2'b00;
			WAddr_d <= 10'b0;
			Wdata_d <= 32'b0;
			_HI <= HI;
			_LO <= LO;
			RA <= 5'b0;
			RB <= 5'b0;
			Finish <= 1'b0;
			RWen <= 1'b0;
			RWAddr <= 5'b0;
			RWdata <= 32'b0;
			reg_use[00] <= 4'b0;
			reg_use[01] <= 4'b0;
			reg_use[02] <= 4'b0;
			reg_use[03] <= 4'b0;
			reg_use[04] <= 4'b0;
			reg_use[05] <= 4'b0;
			reg_use[06] <= 4'b0;
			reg_use[07] <= 4'b0;
			reg_use[08] <= 4'b0;
			reg_use[09] <= 4'b0;
			reg_use[10] <= 4'b0;
			reg_use[11] <= 4'b0;
			reg_use[12] <= 4'b0;
			reg_use[13] <= 4'b0;
			reg_use[14] <= 4'b0;
			reg_use[15] <= 4'b0;
			reg_use[16] <= 4'b0;
			reg_use[17] <= 4'b0;
			reg_use[18] <= 4'b0;
			reg_use[19] <= 4'b0;
			reg_use[20] <= 4'b0;
			reg_use[21] <= 4'b0;
			reg_use[22] <= 4'b0;
			reg_use[23] <= 4'b0;
			reg_use[24] <= 4'b0;
			reg_use[25] <= 4'b0;
			reg_use[26] <= 4'b0;
			reg_use[27] <= 4'b0;
			reg_use[28] <= 4'b0;
			reg_use[29] <= 4'b0;
			reg_use[30] <= 4'b0;
			reg_use[31] <= 4'b0;
			WB_print_reg <= 34'b0;
			print_reg <= 34'b0;
			ID_A <= 32'b0;
			ID_B <= 32'b0;
			EX_A <= 32'b0;
			EX_B <= 32'b0;
			DM_B <= 32'b0;
			EX_ALUOUT <= 32'b0;
			DM_ALUOUT <= 32'b0;
			DM_MDR <= 32'b0;
			EX_ALUReady <= 1'b0;
			DM_ALUReady <= 1'b0;
			DM_MDRReady <= 1'b0;
			WB_ALUReady <= 1'b0;
			WB_MDRReady <= 1'b0;
			stalled <= 1'b0;
			flush <= 1'b0;
		end else begin
			IF_ins <= IF_ins_next;
			ID_ins <= ID_ins_next;
			EX_ins <= EX_ins_next;
			DM_ins <= DM_ins_next;
			WB_ins <= WB_ins_next;
			RAddr_d <= RAddr_d_next;
			Wen <= Wen_next;
			WSize <= WSize_next;
			WAddr_d <= WAddr_d_next;
			Wdata_d <= Wdata_d_next;
			_HI <= _HI_next;
			_LO <= _LO_next;
			RA <= RA_next;
			RB <= RB_next;
			Finish <= Finish_next;
			RWen <= RWen_next;
			RWAddr <= RWAddr_next;
			RWdata <= RWdata_next;
			reg_use[00] <= reg_use_next[00];
			reg_use[01] <= reg_use_next[01];
			reg_use[02] <= reg_use_next[02];
			reg_use[03] <= reg_use_next[03];
			reg_use[04] <= reg_use_next[04];
			reg_use[05] <= reg_use_next[05];
			reg_use[06] <= reg_use_next[06];
			reg_use[07] <= reg_use_next[07];
			reg_use[08] <= reg_use_next[08];
			reg_use[09] <= reg_use_next[09];
			reg_use[10] <= reg_use_next[10];
			reg_use[11] <= reg_use_next[11];
			reg_use[12] <= reg_use_next[12];
			reg_use[13] <= reg_use_next[13];
			reg_use[14] <= reg_use_next[14];
			reg_use[15] <= reg_use_next[15];
			reg_use[16] <= reg_use_next[16];
			reg_use[17] <= reg_use_next[17];
			reg_use[18] <= reg_use_next[18];
			reg_use[19] <= reg_use_next[19];
			reg_use[20] <= reg_use_next[20];
			reg_use[21] <= reg_use_next[21];
			reg_use[22] <= reg_use_next[22];
			reg_use[23] <= reg_use_next[23];
			reg_use[24] <= reg_use_next[24];
			reg_use[25] <= reg_use_next[25];
			reg_use[26] <= reg_use_next[26];
			reg_use[27] <= reg_use_next[27];
			reg_use[28] <= reg_use_next[28];
			reg_use[29] <= reg_use_next[29];
			reg_use[30] <= reg_use_next[30];
			reg_use[31] <= reg_use_next[31];
			WB_print_reg <= WB_print_reg_next;
			print_reg <= print_reg_next;
			ID_A <= ID_A_next;
			ID_B <= ID_B_next;
			EX_A <= EX_A_next;
			EX_B <= EX_B_next;
			DM_B <= DM_B_next;
			EX_ALUOUT <= EX_ALUOUT_next;
			DM_ALUOUT <= DM_ALUOUT_next;
			DM_MDR <= DM_MDR_next;
			EX_ALUReady <= EX_ALUReady_next;
			DM_ALUReady <= DM_ALUReady_next;
			DM_MDRReady <= DM_MDRReady_next;
			WB_ALUReady <= WB_ALUReady_next;
			WB_MDRReady <= WB_MDRReady_next;
			stalled <= stalled_next;
			flush <= flush_next;
		end
	end
	
	always@(posedge clk or posedge rst)begin
		if(rst)begin
			count <= 1'b0;
			_PC <= PC;
		end else begin
			count <= 1'b1;
			_PC <= _PC_next;
		end
	end

	always@(*)begin
		IF_ins_next = Rdata_i;
		RA_next = Rdata_i[25:21];
		RB_next = Rdata_i[20:16];
		case(Rdata_i[31:26])
			6'h00:begin
				case(Rdata_i[5:0])
					6'h20, 6'h21, 6'h22, 6'h24, 6'h25, 6'h26, 6'h27, 6'h28, 6'h2a, 6'h02, 6'h03, 6'h10, 6'h12:begin
						reg_use[Rdata_i[15:11]] = 4'b0001;
					end
					6'h00:begin
						if(!{Rdata_i[31:26],Rdata_i[20:0]})begin
							reg_use[Rdata_i[15:11]] = 4'b0001;
						end
					end
				endcase
			end
			6'h08, 6'h09, 6'h23, 6'h21, 6'h25, 6'h20, 6'h24, 6'h2b, 6'h29, 6'h28, 6'h0f, 6'h0c, 6'h0d, 6'h0e, 6'h0a:begin
				reg_use[Rdata_i[20:16]] = 4'b0001;
			end
		endcase
	end
	always@(*)begin
		ID_ins_next = (flush) ? 32'b0: IF_ins;
		_PC_next = _PC+4;
		ID_A_next = A;
		ID_B_next = B;
		flush_next = 1'b0;
		case(IF_ins[31:26])
			6'h00:begin
				if(IF_ins[5:0]==6'h08)begin
					_PC_next = A;
					flush_next = 1'b1;
				end
			end
			6'h04:begin
				if(A==B)begin
					_PC_next = _PC + {{14{IF_ins[15]}}, IF_ins[15:0], 2'b0};
					flush_next = 1'b1;
				end
			end
			6'h05:begin
				if(A!=B)begin
					_PC_next = _PC + {{14{IF_ins[15]}}, IF_ins[15:0], 2'b0};
					flush_next = 1'b1;
				end
			end
			6'h07:begin
				if(!A[31])begin
					_PC_next = _PC + {{14{IF_ins[15]}}, IF_ins[15:0], 2'b0};
					flush_next = 1'b1;
				end
			end
			6'h02, 6'h03:begin
				_PC_next = { 4'b0, IF_ins[25:0], 2'b0 };
				flush_next = 1'b1;
			end
		endcase
		case(IF_ins[31:26])
			6'h00:begin
				case(IF_ins[5:0])
					6'h20, 6'h21, 6'h22, 6'h24, 6'h25, 6'h26, 6'h27, 6'h28, 6'h2a, 6'h02, 6'h03, 6'h10, 6'h12:begin
						reg_use[IF_ins[15:11]] = 4'b0010;
					end
					6'h00:begin
						if(!{IF_ins[31:26],IF_ins[20:0]})begin
							reg_use[IF_ins[15:11]] = 4'b0010;
						end
					end
				endcase
			end
			6'h08, 6'h09, 6'h23, 6'h21, 6'h25, 6'h20, 6'h24, 6'h2b, 6'h29, 6'h28, 6'h0f, 6'h0c, 6'h0d, 6'h0e, 6'h0a:begin
				reg_use[IF_ins[20:16]] = 4'b0010;
			end
		endcase
	end
	always@(*)begin
		EX_ins_next = ID_ins;
		EX_A_next = ID_A;
		EX_B_next = ID_B;
		if(ID_ins[31:26]==6'h00)begin
			case(ID_ins[5:0])
				6'h18, 6'h19, 6'h10, 6'h12:begin
					EX_ALUOUT_next = 32'b0;
					EX_ALUReady_next = 1'b0;
				end
				default:begin
					ALU(ID_ins, ID_A, ID_B, EX_ALUOUT_next, EX_ALUReady_next);
				end
			endcase
		end
		case(ID_ins[31:26])
			6'h00:begin
				case(ID_ins[5:0])
					6'h20, 6'h21, 6'h22, 6'h24, 6'h25, 6'h26, 6'h27, 6'h28, 6'h2a, 6'h02, 6'h03, 6'h10, 6'h12:begin
						reg_use[ID_ins[15:11]] = 4'b0100;
					end
					6'h00:begin
						if(!{ID_ins[31:26],ID_ins[20:0]})begin
							reg_use[ID_ins[15:11]] = 4'b0100;
						end
					end
				endcase
			end
			6'h08, 6'h09, 6'h23, 6'h21, 6'h25, 6'h20, 6'h24, 6'h2b, 6'h29, 6'h28, 6'h0f, 6'h0c, 6'h0d, 6'h0e, 6'h0a:begin
				reg_use[ID_ins[20:16]] = 4'b0100;
			end
		endcase
	end
	always@(*)begin
		DM_ins_next = EX_ins;
		DM_B_next = EX_B;
		DM_ALUOUT_next = EX_ALUOUT;
		DM_ALUReady_next = EX_ALUReady;
		DM_MDRReady_next = 1'b0;
		case(EX_ins)
			6'h23, 6'h21, 6'h25, 6'h20, 6'h24:begin
				RAddr_d_next = EX_ALUOUT;
				DM_MDRReady_next = 1'b1;
			end
			default:begin
				RAddr_d_next = RAddr_d;
			end
		endcase
		case(EX_ins)
			6'h2b:begin
				Wen_next = 1'b1;
				WSize_next = 2'b11;
				WAddr_d_next = EX_ALUOUT;
				Wdata_d_next = EX_B;
			end
			6'h29:begin
				Wen_next = 1'b1;
				WSize_next = 2'b10;
				WAddr_d_next = EX_ALUOUT;
				Wdata_d_next = EX_B;
			end
			6'h28:begin
				Wen_next = 1'b1;
				WSize_next = 2'b01;
				WAddr_d_next = EX_ALUOUT;
				Wdata_d_next = EX_B;
			end
			default:begin
				Wen_next = 1'b0;
				WSize_next = 2'b00;
				WAddr_d_next = WAddr_d;
				Wdata_d_next = Wdata_d;
			end
		endcase
		case(EX_ins[31:26])
			6'h00:begin
				case(EX_ins[5:0])
					6'h20, 6'h21, 6'h22, 6'h24, 6'h25, 6'h26, 6'h27, 6'h28, 6'h2a, 6'h02, 6'h03, 6'h10, 6'h12:begin
						reg_use[EX_ins[15:11]] = 4'b1000;
					end
					6'h00:begin
						if(!{EX_ins[31:26],EX_ins[20:0]})begin
							reg_use[EX_ins[15:11]] = 4'b1000;
						end
					end
				endcase
			end
			6'h08, 6'h09, 6'h23, 6'h21, 6'h25, 6'h20, 6'h24, 6'h2b, 6'h29, 6'h28, 6'h0f, 6'h0c, 6'h0d, 6'h0e, 6'h0a:begin
				reg_use[EX_ins[20:16]] = 4'b1000;
			end
		endcase
	end
	always@(*)begin
		WB_ins_next = DM_ins;
		WB_print_reg_next = 34'b0;
		WB_ALUReady_next = DM_ALUReady;
		WB_MDRReady_next = DM_MDRReady;
		case(DM_ins[31:26])
			6'h00:begin
				case(DM_ins[5:0])
					6'h18, 6'h19, 6'h08, 6'h10, 6'h12:begin
						RWen_next = 1'b0;
						RWAddr_next = 5'b0;
						RWdata_next = 32'b0;
						WB_print_reg_next = 34'b0;
					end
					default:begin
						RWen_next = 1'b1;
						RWAddr_next = DM_ins[15:11];
						RWdata_next = DM_ALUOUT;
						WB_print_reg_next[DM_ins[15:11]] = 1'b1;		
					end
				endcase
			end
			6'h08, 6'h09, 6'h0f, 6'h0c, 6'h0d, 6'h0e, 6'h0a:begin
				RWen_next = 1'b1;
				RWAddr_next = DM_ins[20:16];
				RWdata_next = DM_ALUOUT;
				WB_print_reg_next[DM_ins[20:16]] = 1'b1;
			end
			6'h03:begin
				RWen_next = 1'b1;
				RWAddr_next = 5'b11111;
				RWdata_next = DM_ALUOUT;
				WB_print_reg_next[5'b11111] = 1'b1;
			end
			6'h23:begin
				RWen_next = 1'b1;
				RWAddr_next = DM_ins[20:16];
				RWdata_next = Rdata_d;
				WB_print_reg_next[DM_ins[20:16]] = 1'b1;
			end
			6'h21:begin
				RWen_next = 1'b1;
				RWAddr_next = DM_ins[20:16];
				RWdata_next = {{16{Rdata_d[15]}},Rdata_d[15:0]};
				WB_print_reg_next[DM_ins[20:16]] = 1'b1;
			end
			6'h25:begin
				RWen_next = 1'b1;
				RWAddr_next = DM_ins[20:16];
				RWdata_next = {{16{1'b0}},Rdata_d[15:0]};
				WB_print_reg_next[DM_ins[20:16]] = 1'b1;
			end
			6'h20:begin
				RWen_next = 1'b1;
				RWAddr_next = DM_ins[20:16];
				RWdata_next = {{24{Rdata_d[7]}},Rdata_d[7:0]};
				WB_print_reg_next[DM_ins[20:16]] = 1'b1;
			end
			6'h24:begin
				RWen_next = 1'b1;
				RWAddr_next = DM_ins[20:16];
				RWdata_next = {{24{1'b0}},Rdata_d[7:0]};
				WB_print_reg_next[DM_ins[20:16]] = 1'b1;
			end
			default:begin
				RWen_next = 1'b0;
				RWAddr_next = 5'b0;
				RWdata_next = 32'b0;
				WB_print_reg_next = 34'b0;
			end
		endcase
	end
	always@(*)begin
		print_reg_next = WB_print_reg;
	end
	always@(*)begin
		Finish_next = (&ID_ins[31:26]) & (&EX_ins[31:26]) & (&DM_ins[31:26]) & (&WB_ins[31:26]);
	end

	task ALU;
		input [31:0] ins;
		input [31:0] A, B;
		output reg [31:0] ALUOut;
		output reg ALUReady;

		case(ins[31:26])
			6'h00:begin
				case(ins[5:0])
					6'h20, 6'h21:begin
						ALUOut = A + B;
						ALUReady = 1'b1;
					end
					6'h22:begin
						ALUOut = A - B;
						ALUReady = 1'b1;
					end
					6'h24:begin
						ALUOut = A & B;
						ALUReady = 1'b1;
					end
					6'h25:begin
						ALUOut = A | B;
						ALUReady = 1'b1;
					end
					6'h26:begin
						ALUOut = A ^ B;
						ALUReady = 1'b1;
					end
					6'h27:begin
						ALUOut = ~(A | B);
						ALUReady = 1'b1;
					end
					6'h28:begin
						ALUOut = ~(A & B);
						ALUReady = 1'b1;
					end
					6'h2a:begin
						ALUOut = $signed(A) < $signed(B);
						ALUReady = 1'b1;
					end
					6'h00:begin
						ALUOut = B << ins[10:6];
						ALUReady = 1'b1;
					end
					6'h02:begin
						ALUOut = B >> ins[10:6];
						ALUReady = 1'b1;
					end
					6'h03:begin
						ALUOut = {{32{B[31]}}, B} >> ins[10:6];
						ALUReady = 1'b1;
					end
					default:begin
						ALUOut = 32'b0;
						ALUReady = 1'b0;
					end
				endcase
			end
			6'h08, 6'h09:begin
				ALUOut = A + {{16{ins[15]}},ins[15:0]};
				ALUReady = 1'b1;
			end
			6'h23, 6'h21, 6'h25, 6'h20, 6'h24, 6'h2b, 6'h29, 6'h28:begin
				ALUOut = A + {{16{ins[15]}},ins[15:0]};
				ALUReady = 1'b0;
			end
			6'h0f:begin
				ALUOut = {ins[15:0], 16'b0};
				ALUReady = 1'b1;
			end
			6'h0c:begin
				ALUOut = A & {16'b0, ins[15:0]};
				ALUReady = 1'b1;
			end
			6'h0d:begin
				ALUOut = A | {16'b0, ins[15:0]};
				ALUReady = 1'b1;
			end
			6'h0e:begin
				ALUOut = ~( A | {16'b0, ins[15:0]} );
				ALUReady = 1'b1;
			end
			6'h0a:begin
				ALUOut = $signed(A)< $signed({{16{ins[15]}}, ins[15:0]});
				ALUReady = 1'b1;
			end
			default:begin
				ALUOut = 32'b0;
				ALUReady = 1'b0;
			end
		endcase		

	endtask

endmodule
