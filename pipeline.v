module pipeline(clk, rst, IF_ins, ID_ins, EX_ins, DM_ins, WB_ins, HI, LO, PC, Rdata_i, RAddr_d, Rdata_d, Wen, WSize, WAddr_d, Wdata_d, _HI, _LO, _PC, RA, RB, A, B, Finish, RWen, RWAddr, RWdata, print_reg, stalled, flush, rs, rt, EX_DM_to_ID, EX_DM_to_ID_reg);

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
	output reg stalled, flush;
	output reg rs, rt, EX_DM_to_ID;
	output reg [4:0] EX_DM_to_ID_reg;

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

	reg [33:0] WB_print_reg, WB_print_reg_next;
	reg [33:0] print_reg_next;

	reg signed [31:0] ID_A, ID_B, ID_A_next, ID_B_next;
	reg signed [31:0] EX_A, EX_B, EX_A_next, EX_B_next;
	reg signed [31:0] DM_B, DM_B_next;
	reg [31:0] EX_ALUOUT, EX_ALUOUT_next;
	reg [31:0] DM_ALUOUT, DM_ALUOUT_next, DM_MDR, DM_MDR_next;
	reg count;
	reg stalled_next;
	reg flush_next;
	reg [4:0]ID_write, ID_write_next;
	reg ID_dataready, ID_dataready_next;
	reg [31:0]ID_data, ID_data_next;
	reg [4:0]EX_write, EX_write_next;
	reg EX_dataready, EX_dataready_next;
	reg [31:0]EX_data, EX_data_next;
	reg [4:0]DM_write, DM_write_next;
	reg DM_dataready, DM_dataready_next;
	reg [31:0]DM_data, DM_data_next;
	reg [4:0]WB_write, WB_write_next;
	reg WB_dataready, WB_dataready_next;
	reg [31:0]WB_data, WB_data_next;
	reg _is_A, _is_B;
	reg [31:0] _A_, _B_;

	reg rs_next, rt_next, EX_DM_to_ID_next;
	reg [4:0] EX_DM_to_ID_reg_next;

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
			stalled <= 1'b0;
			flush <= 1'b0;
			ID_write <= 5'b0;
			ID_dataready <= 1'b0;
			ID_data <= 32'b0;
			EX_write <= 5'b0;
			EX_dataready <= 1'b0;
			EX_data <= 32'b0;
			DM_write <= 5'b0;
			DM_dataready <= 1'b0;
			DM_data <= 32'b0;
			WB_write <= 5'b0;
			WB_dataready <= 1'b0;
			WB_data <= 32'b0;
			rs <= 1'b0;
			rt <= 1'b0;
			EX_DM_to_ID <= 1'b0;
			EX_DM_to_ID_reg <= 5'b0;
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
			stalled <= stalled_next;
			flush <= flush_next;
			ID_write <= ID_write_next;
			ID_dataready <= ID_dataready_next;
			ID_data <= ID_data_next;
			EX_write <= EX_write_next;
			EX_dataready <= EX_dataready_next;
			EX_data <= EX_data_next;
			DM_write <= DM_write_next;
			DM_dataready <= DM_dataready_next;
			DM_data <= DM_data_next;
			WB_write <= WB_write_next;
			WB_dataready <= WB_dataready_next;
			WB_data <= WB_data_next;
			rs <= rs_next;
			rt <= rt_next;
			EX_DM_to_ID <= EX_DM_to_ID_next;
			EX_DM_to_ID_reg <= EX_DM_to_ID_reg_next;
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
		if(stalled)begin
			IF_ins_next = IF_ins;
		end else begin
			IF_ins_next = Rdata_i;
		end
		RA_next = Rdata_i[25:21];
		RB_next = Rdata_i[20:16];
	end
	always@(*)begin
		if(stalled)begin
			ID_ins_next = ID_ins;
		end else begin
			ID_ins_next = (flush) ? 32'b0: IF_ins;
		end
		ID_write_next = 5'b0;
		ID_dataready_next = 1'b0;
		ID_data_next = 32'b0;
		flush_next = 1'b0;
		_stall(ID_ins_next, stalled_next, _is_A, _is_B, _A_, _B_, rs_next, rt_next, EX_DM_to_ID_next, EX_DM_to_ID_reg_next);
		if(!stalled_next)begin
		_PC_next = _PC+4;
		ID_A_next = (_is_A) ? _A_: A;
		ID_B_next = (_is_B) ? _B_: B;
		case(IF_ins[31:26])
			6'h00:begin
				case(IF_ins[5:0])
					6'h20, 6'h21, 6'h22, 6'h24, 6'h25, 6'h26, 6'h27, 6'h28, 6'h2a, 6'h00, 6'h02, 6'h03:begin
						ID_write_next = IF_ins[15:11];
					end
				endcase
			end
			6'h08, 6'h09, 6'h23, 6'h21, 6'h25, 6'h20, 6'h24, 6'h0f, 6'h0c, 6'h0d, 6'h0e, 6'h0a:begin
				ID_write_next = IF_ins[20:16];
			end
		endcase
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
		end
	end
	always@(*)begin
		if(stalled)begin
			EX_ins_next = 32'b0;
			EX_A_next = 32'b0;
			EX_B_next = 32'b0;
			EX_write_next = 5'b0;
			EX_dataready_next = 1'b0;
			EX_data_next = 32'b0;
			RAddr_d_next = RAddr_d;
			EX_ALUOUT_next = 32'b0;
		end else begin
			EX_ins_next = ID_ins;
			EX_A_next = ID_A;
			EX_B_next = ID_B;
			EX_write_next = ID_write;
			EX_dataready_next = ID_dataready;
			EX_data_next = ID_data;
			RAddr_d_next = RAddr_d;
			EX_ALUOUT_next = 32'b0;
			case(ID_ins[31:26])
				6'h00:begin
					case(ID_ins[5:0])
						6'h18, 6'h19, 6'h10, 6'h12:begin
							EX_ALUOUT_next = 32'b0;
						end
						default:begin
							ALU(ID_ins, ID_A, ID_B, EX_ALUOUT_next, EX_dataready_next);
							EX_data_next = EX_ALUOUT_next;
						end
					endcase
				end
				6'h23, 6'h21, 6'h25, 6'h20, 6'h24:begin
					ALU(ID_ins, ID_A, ID_B, RAddr_d_next, EX_dataready_next);
				end
				6'h08, 6'h09, 6'h2b, 6'h29, 6'h28, 6'h0f, 6'h0c, 6'h0d, 6'h0e, 6'h0a:begin
					ALU(ID_ins, ID_A, ID_B, EX_ALUOUT_next, EX_dataready_next);
				end
			endcase
		end
	end
	always@(*)begin
		DM_ins_next = EX_ins;
		DM_B_next = EX_B;
		DM_ALUOUT_next = EX_ALUOUT;
		DM_write_next = EX_write;
		DM_dataready_next = EX_dataready;
		DM_data_next = EX_data;
		case(EX_ins[31:26])
			6'h23:begin
				DM_MDR_next = Rdata_d;
				DM_dataready_next = 1'b1;
				DM_data_next = Rdata_d;
			end
			6'h21:begin
				DM_MDR_next = {{16{Rdata_d[15]}},Rdata_d[15:0]};
				DM_dataready_next = 1'b1;
				DM_data_next = {{16{Rdata_d[15]}},Rdata_d[15:0]};
			end
			6'h25:begin
				DM_MDR_next = {{16{1'b0}},Rdata_d[15:0]};
				DM_dataready_next = 1'b1;
				DM_data_next = {{16{1'b1}},Rdata_d[15:0]};
			end
			6'h20:begin
				DM_MDR_next = {{24{Rdata_d[7]}},Rdata_d[7:0]};
				DM_dataready_next = 1'b1;
				DM_data_next = {{24{Rdata_d[7]}},Rdata_d[7:0]};
			end
			6'h24:begin
				DM_MDR_next = {{24{1'b0}},Rdata_d[7:0]};
				DM_dataready_next = 1'b1;
				DM_data_next = {{24{1'b0}},Rdata_d[7:0]};
			end
			default:begin
				DM_MDR_next = 32'b0;
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
	end
	always@(*)begin
		WB_ins_next = DM_ins;
		WB_print_reg_next = 34'b0;
		WB_write_next = DM_write;
		WB_dataready_next = DM_dataready;
		WB_data_next = DM_data;
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
			6'h23, 6'h21, 6'h25, 6'h20, 6'h24:begin
				RWen_next = 1'b1;
				RWAddr_next = DM_ins[20:16];
				RWdata_next = DM_MDR;
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
		output reg dataReady;

		begin
		ALUOut = 32'b0;
		case(ins[31:26])
			6'h00:begin
				case(ins[5:0])
					6'h20, 6'h21:begin
						ALUOut = A + B;
						dataReady = 1'b1;
					end
					6'h22:begin
						ALUOut = A - B;
						dataReady = 1'b1;
					end
					6'h24:begin
						ALUOut = A & B;
						dataReady = 1'b1;
					end
					6'h25:begin
						ALUOut = A | B;
						dataReady = 1'b1;
					end
					6'h26:begin
						ALUOut = A ^ B;
						dataReady = 1'b1;
					end
					6'h27:begin
						ALUOut = ~(A | B);
						dataReady = 1'b1;
					end
					6'h28:begin
						ALUOut = ~(A & B);
						dataReady = 1'b1;
					end
					6'h2a:begin
						ALUOut = $signed(A) < $signed(B);
						dataReady = 1'b1;
					end
					6'h00:begin
						ALUOut = B << ins[10:6];
						dataReady = 1'b1;
					end
					6'h02:begin
						ALUOut = B >> ins[10:6];
						dataReady = 1'b1;
					end
					6'h03:begin
						ALUOut = {{32{B[31]}}, B} >> ins[10:6];
						dataReady = 1'b1;
					end
					default:begin
						ALUOut = 32'b0;
						dataReady = 1'b0;
					end
				endcase
			end
			6'h08, 6'h09:begin
				ALUOut = A + {{16{ins[15]}},ins[15:0]};
				dataReady = 1'b1;
			end
			6'h23, 6'h21, 6'h25, 6'h20, 6'h24, 6'h2b, 6'h29, 6'h28:begin
				ALUOut = A + {{16{ins[15]}},ins[15:0]};
				dataReady = 1'b0;
			end
			6'h0f:begin
				ALUOut = {ins[15:0], 16'b0};
				dataReady = 1'b1;
			end
			6'h0c:begin
				ALUOut = A & {16'b0, ins[15:0]};
				dataReady = 1'b1;
			end
			6'h0d:begin
				ALUOut = A | {16'b0, ins[15:0]};
				dataReady = 1'b1;
			end
			6'h0e:begin
				ALUOut = ~( A | {16'b0, ins[15:0]} );
				dataReady = 1'b1;
			end
			6'h0a:begin
				ALUOut = $signed(A)< $signed({{16{ins[15]}}, ins[15:0]});
				dataReady = 1'b1;
			end
			default:begin
				ALUOut = 32'b0;
				dataReady = 1'b0;
			end
		endcase		
	end
	endtask

	task _stall;
		input [31:0] ins;
		output reg stall;
		output reg is_A, is_B;
		output reg [31:0] _A, _B;
		output reg _rs, _rt, ED_to_ID;
		output reg [4:0] ED_to_ID_reg;

		reg needA, needB;	
		reg stallA, stallB;
		begin
		stallA = 1'b0;
		stallB = 1'b0;
		needA = 1'b0;
		needB = 1'b0;
		is_A = 1'b0;
		is_B = 1'b0;
		_rs = 1'b0;
		_rt = 1'b0;
		ED_to_ID = 1'b0;
		ED_to_ID_reg = 5'b0;
		case(ins[31:26])
			6'h00:begin
				case(ins[5:0])
					6'h20, 6'h21, 6'h22, 6'h24, 6'h25, 6'h26, 6'h27, 6'h28, 6'h2a:begin
						needA = 1'b1;
						needB = 1'b1;
					end
					6'h00:begin
						if(|ins[31:0])begin
							needA = 1'b0;
							needB = 1'b1;
						end
					end
					6'h02, 6'h03:begin
						needA = 1'b0;
						needB = 1'b1;
					end
					default:begin
						needA = 1'b0;
						needB = 1'b0;
					end
				endcase
			end
			6'h08, 6'h09, 6'h23, 6'h21, 6'h25, 6'h20, 6'h24, 6'h0c, 6'h0d, 6'h0e, 6'h0a, 6'h07:begin
				needA = 1'b1;
				needB = 1'b0;
			end
			6'h2b, 6'h29, 6'h28, 6'h04, 6'h05:begin
				needA = 1'b1;
				needB = 1'b1;
			end
			default:begin
				needA = 1'b0;
				needB = 1'b0;
			end
		endcase
		if(needA)begin
			case(ins[25:21])
				EX_write:begin
					if(EX_dataready)begin
						stallA = 1'b0;
						is_A = 1'b1;
						_A = EX_data;
						_rs = 1'b1;
						ED_to_ID = 1'b1;
						ED_to_ID_reg = EX_write;
					end else begin
						stallA = 1'b1;
						is_A = 1'b0;
						_A = 32'b0;
					end
				end
				DM_write:begin
					if(DM_dataready)begin
						stallA = 1'b0;
						is_A = 1'b1;
						_A = DM_data;
					end else begin
						stallA = 1'b1;
						is_A = 1'b0;
						_A = 32'b0;
					end
				end
/*				WB_write:begin
					if(WB_dataready)begin
						stallA = 1'b0;
						is_A = 1'b1;
						_A = WB_data;
					end else begin
						stallA = 1'b1;
						is_A = 1'b0;
						_A = 32'b0;
					end
				end*/
				default:begin
					stallA = 1'b0;
					is_A = 1'b0;
					_A = 32'b0;
				end
			endcase
		end
		if(needB & (|ins[20:16]))begin
			case(ins[20:16])
				EX_write:begin
					if(EX_dataready)begin
						stallB = 1'b0;
						is_B = 1'b1;
						_B = EX_data;
						_rt = 1'b1;
						ED_to_ID = 1'b1;
						ED_to_ID_reg = EX_write;
					end else begin
						stallB = 1'b1;
						is_B = 1'b0;
						_B = 32'b0;
					end
				end
				DM_write:begin
					if(DM_dataready)begin
						stallB = 1'b0;
						is_B = 1'b1;
						_B = DM_data;
					end else begin
						stallB = 1'b1;
						is_B = 1'b0;
						_B = 32'b0;
					end
				end
/*				WB_write:begin
					if(WB_dataready)begin
						stallB = 1'b0;
						is_B = 1'b1;
						_B = WB_data;
					end else begin
						stallB = 1'b1;
						is_B = 1'b0;
						_B = 32'b0;
					end
				end*/
				default:begin
					stallB = 1'b0;
					is_B = 1'b0;
					_B = 32'b0;
				end
			endcase
		end
		stall = stallA | stallB;
	end
	endtask

endmodule
