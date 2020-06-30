
// @file controller.v
// @breif controller(コントローラ)
// @author Yusuke Matsunaga (松永 裕介)
//
// Copyright (C) 2019 Yusuke Matsunaga
// All rights reserved.
//
// [概要]
// データパスを制御する信号を生成する．
// フェイズは phasegen が生成するので
// このモジュールは完全な組み合わせ回路となる．
//
// [入力]
// cstate:     動作フェイズを表す4ビットの信号
// ir:         IRレジスタの値
// addr:       メモリアドレス(mem_wrbitsの生成に用いる)
// alu_out:    ALUの出力(分岐命令の条件判断に用いる)
//
// [出力]
// pc_sel:     PCの入力選択
// pc_ld:      PCの書き込み制御
// mem_sel:    メモリアドレスの入力選択
// mem_read:   メモリの読み込み制御
// mem_write:  メモリの書き込み制御
// mem_wrbits: メモリの書き込みビットマスク
// ir_ld:      IRレジスタの書き込み制御
// rs1_addr:   RS1アドレス
// rs2_addr:   RS2アドレス
// rd_addr:    RDアドレス
// rd_sel:     RDの入力選択
// rd_ld:      RDの書き込み制御
// a_ld:       Aレジスタの書き込み制御
// b_ld:       Bレジスタの書き込み制御
// a_sel:      ALUの入力1の入力選択
// b_sel:      ALUの入力2の入力選択
// imm:        即値
// alu_ctl:    ALUの機能コード
// c_ld:       Cレジスタの書き込み制御
module controller(input [3:0]   cstate,//動作フェイズを表す4ビットの信号
		  input [31:0] 	ir,//IRレジスタの値(current instruction)
		  input [31:0]  addr,//メモリアドレス(mem_wrbitsの生成に用いる)
		  input [31:0] 	alu_out,//ALUの出力(分岐命令の条件判断に用いる)
// ----------------------------------------------------------------------
		  output 	pc_sel,//PCの入力選択
		  output 	pc_ld,//PCの書き込み制御
// ----------------------------------------------------------------------
		  output 	mem_sel,//メモリアドレスの入力選択
		  output 	mem_read,//メモリの読み込み制御
		  output 	mem_write,//メモリの書き込み制御
		  output [3:0] 	mem_wrbits,//メモリの書き込みビットマスク
// ----------------------------------------------------------------------
		  output 	ir_ld,//IRレジスタの書き込み制御
// ----------------------------------------------------------------------
		  output [4:0] 	rs1_addr,
		  output [4:0] 	rs2_addr,
		  output [4:0] 	rd_addr,
// ----------------------------------------------------------------------
		  output [1:0] 	rd_sel,//RDの入力選択
		  output 	rd_ld,//RDの書き込み制御
// ----------------------------------------------------------------------
		  output 	a_ld,//Aレジスタの書き込み制御
		  output 	b_ld,//Bレジスタの書き込み制御
// ----------------------------------------------------------------------
		  output 	a_sel,//ALUの入力1の入力選択
		  output 	b_sel,//ALUの入力2の入力選択
// ----------------------------------------------------------------------
		  output [31:0] imm,
// ----------------------------------------------------------------------
		  output [3:0] 	alu_ctl,//ALUの機能コード
// ----------------------------------------------------------------------
		  output 	c_ld);//Cレジスタの書き込み制御
// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

// ------------------PC Control--------------------------
		  wire [1:0] pc_ctrl;
		   
		  function [1:0] pc(input [3:0] cstate, input [31:0] ir, input [31:0] alu_out);//ret [pc_ld,pc_sel]
			  if (cstate==4'b1000&&(ir[6:0]==7'b1101111||ir[6:0]==7'b1100111)) begin //WB jal,jalr PC=Creg
				//   pc_ld=1;
				//   pc_sel=1;
				  pc=2'b11;
			  end
			  else if (cstate==4'b1000&&ir[6:0]==7'b1100011&&alu_out==32'b1) begin //WB beq... PC=Creg
				// pc_ld=1;
				// pc_sel=1;
				pc=2'b11;
			  end
			  else if (cstate==4'b1000) begin//WB others PC=PC+4
				//   pc_ld=1;
				//   pc_sel=0;
				  pc=2'b10;
			  end
			  else begin
				//   pc_ld=0;
				//   pc_sel=0;
				pc=2'b00;
			  end
		  endfunction

		  assign pc_ctrl=pc(cstate,ir,alu_out);

		  assign pc_ld=pc_ctrl[1];
		  assign pc_sel=pc_ctrl[0];

// --------------------Memory Control-------------------------
			wire [6:0] mem_ctrl;

			function [6:0] mem(input [3:0] cstate, input [31:0] ir,input [31:0] addr);//ret [mem_sel,mem_read,mem_write,mem_wrbits[3:0]]
				if(cstate==4'b0001)begin//IF
					// mem_sel=0;
					// mem_read=0;
					// mem_write=0;
					// mem_wrbits=0000;
					mem=7'b0100000;
				end
				else if(cstate==4'b1000)begin//WB
					// mem_sel=1;
					if(ir[6:0]==7'b0000011)begin//load
						// mem_read=1;
						// mem_write=0;
						// mem_wrbits=0000;
						mem=7'b1100000;
					end
					else if(ir[6:0]==7'b0100011)begin//store
						// mem_read=0;
						// mem_write=1;
						case (ir[14:12])
							3'b000://sb mem_wrbits=addr[1:0]:0001,0010,0100,1000
								begin
									case (addr[1:0])
										2'b00: mem=7'b1010001;
										2'b01: mem=7'b1010010;
										2'b10: mem=7'b1010100;
										2'b11: mem=7'b1011000;
									endcase
								end
							3'b001://sh mem_wrbits=addr[1:0]:00->0011,10->1100
								begin
									case (addr[1:0])
										2'b00: mem=7'b1010011;
										2'b10: mem=7'b1011100;
									endcase
								end
							3'b010://sw mem_wrbits=1111
								begin
									mem=7'b1011111;
								end
							default: begin
							end
						endcase
					end
				end
				else begin
					mem=7'b0000000;
				end
			endfunction

			assign mem_ctrl=mem(cstate,ir,addr);

			assign mem_sel=mem_ctrl[6];
			assign mem_read=mem_ctrl[5];
			assign mem_write=mem_ctrl[4];
			assign mem_wrbits=mem_ctrl[3:0];

// -----------------------IR Control------------------------------
			assign ir_ld=(cstate==4'b0001)?1:0;

// -------------------------Reg File Control1-------------------------
			assign rs1_addr=ir[19:15];
			assign rs2_addr=ir[24:20];
			assign rd_addr=ir[11:7];

// ----------------------------Reg File Control2------------------------
			assign a_ld=(cstate==4'b0010)?1:0;
			assign b_ld=(cstate==4'b0010)?1:0;

// ----------------------Reg File Control3(rd_sel,rd_ld)------------------------
			wire [2:0] regfile_ctrl;

			function [2:0] regf(input [3:0] cstate,input [31:0] ir);
			//ret [rd_ld,rd_sel[1:0]]
				if(cstate==4'b1000)begin
					// rd_ld=1;
					case (ir[6:0])
						7'b0110111:regf=3'b110;
						7'b0010111:regf=3'b110;
						7'b0010011:regf=3'b110;
						7'b0110011:regf=3'b110;

						// 7'b1101111:regf=3'b101;
						// 7'b1100111:regf=3'b101;
						//

						7'b0000011:regf=3'b100;
						default:regf=3'b000;
					endcase
				end
				///////test////////
				else if(cstate==4'b0010)begin//EX
					case(ir[6:0])
						7'b1101111:regf=3'b101;//jal
						7'b1100111:regf=3'b101;//jalr
					endcase
				end
				///////test////////
				else begin
					regf=3'b000;
				end
			endfunction

			assign regfile_ctrl=regf(cstate,ir);

			assign rd_sel=regfile_ctrl[1:0];
			assign rd_ld=regfile_ctrl[2];

// --------------------------------imm generation(imm)------------------------
			function [31:0] imm_num(input [31:0] ir);
				case (ir[6:0])
					7'b1100111: imm_num={{20{ir[31]}},{ir[31:20]}};
					7'b0000011: imm_num={{20{ir[31]}},{ir[31:20]}};
					7'b0010011: begin
						case(ir[14:12])
							3'b001: imm_num={{27'b0},{ir[24:20]}};
							3'b101: imm_num={{27'b0},{ir[24:20]}};
							default:begin
								imm_num={{20{ir[31]}},{ir[31:20]}};
							end
						endcase
					end

					7'b0100011: imm_num={{20{ir[31]}},{ir[31:25]},{ir[11:7]}};//S type

					7'b1100011:imm_num={{20{ir[31]}},{ir[7]},{ir[30:25]},{ir[11:8]},{1'b0}};//B type

					7'b0110111:imm_num={{ir[31:12]},{12{1'b0}}};
					7'b0010111:imm_num={{ir[31:12]},{12{1'b0}}};//U type

					7'b1101111:imm_num={{12{ir[31]}},{ir[19:12]},{ir[20]},{ir[30:21]},{1'b0}};//J type
					default:imm_num={32'b0};
				endcase
			endfunction

			assign imm=imm_num(ir);
// -------------ALU Control(a_sel,b_sel,alu_ctl)--------------------------------
			parameter [3:0] ALU_LUI = 4'b0000;
   			parameter [3:0] ALU_EQ  = 4'b0010;
   			parameter [3:0] ALU_NE  = 4'b0011;
   			parameter [3:0] ALU_LT  = 4'b0100;
   			parameter [3:0] ALU_GE  = 4'b0101;
   			parameter [3:0] ALU_LTU = 4'b0110;
   			parameter [3:0] ALU_GEU = 4'b0111;
   			parameter [3:0] ALU_ADD = 4'b1000;
   			parameter [3:0] ALU_SUB = 4'b1001;
   			parameter [3:0] ALU_XOR = 4'b1010;
   			parameter [3:0] ALU_OR  = 4'b1011;
   			parameter [3:0] ALU_AND = 4'b1100;
   			parameter [3:0] ALU_SLL = 4'b1101;
   			parameter [3:0] ALU_SRL = 4'b1110;
   			parameter [3:0] ALU_SRA = 4'b1111;

			wire [5:0] alu_ctrl;

			function [5:0] alu(input [3:0] cstate, input [31:0] ir);
			//ret [asel,bsel,alu_ctl[3:0]]
				if(cstate==4'b0100)begin
					case (ir[6:0])
						7'b0110011:begin //ADD series
							// if(ir[31:25]==7'b0000001)begin//multiply and divide
							// 	case (ir[14:12])
							// 		3'b000:
							// 	endcase
							// end
							// else begin
								case (ir[14:12])
								3'b000:begin
									case(ir[31:25])
										7'b0000000:alu={{2'b00},{ALU_ADD}};
										7'b0100000:alu={{2'b00},{ALU_SUB}};
									endcase
								end
								3'b001:alu={{2'b00},{ALU_SLL}};
								3'b010:alu={{2'b00},{ALU_LT}};
								3'b011:alu={{2'b00},{ALU_LTU}};
								3'b100:alu={{2'b00},{ALU_XOR}};
								3'b101:begin
									case (ir[31:25])
										7'b0000000:alu={{2'b00},{ALU_SRL}};
										7'b0100000:alu={{2'b00},{ALU_SRA}};
									endcase
								end
								3'b110:alu={{2'b00},{ALU_OR}};
								3'b111:alu={{2'b00},{ALU_AND}};
								endcase
							// end
						end
						7'b0010011:begin //ADDI series
							//asel,bsel=0,1
							case (ir[14:12])
								3'b000:alu={{2'b01},{ALU_ADD}};
								3'b010:alu={{2'b01},{ALU_LT}};
								3'b011:alu={{2'b01},{ALU_LTU}};
								3'b100:alu={{2'b01},{ALU_XOR}};
								3'b110:alu={{2'b01},{ALU_OR}};
								3'b111:alu={{2'b01},{ALU_AND}};
								3'b001:alu={{2'b01},{ALU_SLL}};
								3'b101:begin
									case (ir[31:25])
										7'b0000000:alu={{2'b01},{ALU_SRL}};
										7'b0100000:alu={{2'b01},{ALU_SRA}};
									endcase
								end
							endcase
						end
						7'b0000011:begin//load
							//asel,bsel=0,1
							alu={{2'b01},{ALU_ADD}};
						end	
						7'b0100011:begin//store
							alu={{2'b01},{ALU_ADD}};
						end	
						7'b0110111:begin//lui
							alu={{2'b01},{ALU_LUI}};
						end	
						7'b0010111:begin//auipc
							//asel,bsel=1,1
							alu={{2'b11},{ALU_ADD}};
						end	
						7'b1101111:begin//jal
							alu={{2'b11},{ALU_ADD}};
						end	
						7'b1100111:begin//jalr
							alu={{2'b01},{ALU_ADD}};
						end
						7'b1100011:begin//BEQ series
						//asel,bsel=1,1
							alu={{2'b11},{ALU_ADD}};
							
						end
					endcase
				end
				else if(cstate==4'b1000)begin//WB phase
					if(ir[6:0]==7'b1100011)begin// conditional jump
						case (ir[14:12])
								3'b000: alu={{2'b00},{ALU_EQ}};
								3'b001: alu={{2'b00},{ALU_NE}};
								3'b100: alu={{2'b00},{ALU_LT}};
								3'b101: alu={{2'b00},{ALU_GE}};
								3'b110: alu={{2'b00},{ALU_LTU}};
								3'b111: alu={{2'b00},{ALU_GEU}};
						endcase
					end
				end
				else begin
					alu={6'b0};
				end
			endfunction

			assign alu_ctrl=alu(cstate,ir);

			assign a_sel=alu_ctrl[5];
			assign b_sel=alu_ctrl[4];
			assign alu_ctl=alu_ctrl[3:0];

// ---------------------------------C Reg------------------------------------
			assign c_ld=(cstate==4'b0100)?1:0;



endmodule // controller
