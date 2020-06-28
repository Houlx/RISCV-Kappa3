
// @file phasegen.v
// @breif フェーズジェネレータ
// @author Yusuke Matsunaga (松永 裕介)
//
// Copyright (C) 2019 Yusuke Matsunaga
// All rights reserved.
//
// [概要]
// 命令フェイズを生成する．
//
// cstate = {cs_wb, cs_ex, cs_de, cs_if}
// で，常に1つのビットのみ1になっている．
// cs_wb = cstate[3], cs_if = cstate[0]
// であることに注意．
// 各ビットの意味は以下の通り．
// cs_if: IF フェーズ
// cs_de: DE フェーズ
// cs_ex: EX フェーズ
// cs_wb: WB フェーズ
//
// [入出力]
// clock:      クロック信号(立ち上がりエッジ)
// reset:      リセット信号(0でリセット)
// run:        実行開始
// step_phase: 1フェイズ実行
// step_inst:  1命令実行
// cstate:     命令実行フェーズを表すビットベクタ
// running:    実行中を表す信号
module phasegen(input  	     clock,
		input 	     reset,
		
		input 	     run,
		input 	     step_phase,
		input 	     step_inst,
		
		output [3:0] cstate,
		output      running);
		
//		CSTATE
		localparam IF = 4'b0001;
		localparam DE = 4'b0010;
		localparam EX = 4'b0100;
		localparam WB = 4'b1000;
		
//		Inner Status
		localparam STOP       = 2'b00;
		localparam RUN        = 2'b01;
		localparam STEP_INST  = 2'b10;
		localparam STEP_PHASE = 2'b11;

		reg [1:0] inn_sts;
		reg [3:0] phase;
		reg run_sts;

		
		function [3:0] next(input [3:0] phase);
			case(phase)
				IF: next=DE;
				DE: next=EX;
				EX: next=WB;
				WB: next=IF;
				default:next=IF;
			endcase
		endfunction
		
		always @ (posedge clock or negedge reset) begin
			if(!reset) begin
				phase <= IF;
				inn_sts <= STOP;
				run_sts<=0;
			end
			else if(run) begin
				if(inn_sts==STOP)begin
					inn_sts<=RUN;
					// if(phase==WB)begin
					// 	run_sts<=0;
					// end
					// else
					run_sts<=1;
					// phase<=next(phase);
				end
				else if(inn_sts==RUN)begin
					inn_sts<=STOP;
					run_sts<=0;
				end
			end
			else if(step_inst) begin
				case(inn_sts)
					STOP:      begin
									inn_sts<=STEP_INST;
									run_sts<=1;
								  end
					RUN:       phase<=next(phase);
					STEP_INST: begin
									 if(phase==WB)begin
										inn_sts<=STOP;
										run_sts<=0;
									 end
									 phase<=next(phase);
								  end
					default:begin
					end
				endcase
			end
			else if(step_phase) begin
				case(inn_sts)
					STOP:      begin
					            inn_sts<=STEP_PHASE;
					            run_sts<=1;
					           end
					RUN:       phase<=next(phase);
					STEP_PHASE:begin
									inn_sts<=STOP;
									run_sts<=0;
									phase<=next(phase);
								  end
					default:begin
					end
				endcase
			end
		end

		// integer i;
		// always @(posedge clock or negedge reset) begin
		// 	if(!reset)begin
		// 		phase <= IF;
		// 		inn_sts <= STOP;
		// 		run_sts<=0;
		// 	end
		// 	// else if(run)begin
		// 		// if(inn_sts==STOP)begin
		// 			inn_sts<=RUN;
		// 			run_sts<=1;
		// 			// for (i = 0; i<4;i=i+1 ) begin
						
		// 			// end
		// 			// inn_sts<=STOP;
		// 			// run_sts<=0;
		// 		// end
		// 	// end
		// 	phase<=next(phase);
		// end
		
		assign cstate=phase;
		assign running=run_sts;

endmodule // phasegen
