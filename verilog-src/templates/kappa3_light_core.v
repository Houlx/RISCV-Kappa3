
// @file kappa3_light_core_dp.v
// @breif KAPPA3-LIGHT のデータパス
// @author Yusuke Matsunaga (松永 裕介)
//
// Copyright (C) 2019 Yusuke Matsunaga
// All rights reserved.
//
// [概要]
// KAPPA3-LIGHT のデータパス(正確にはレジスタとメモリ)のみのモジュール
// debugger で各レジスタにアクセスすることを目的としている．
//
// [入出力]
// clock:         クロック
// clock2:        clock を2分周したもの
// reset:         リセット
// run:           実行開始
// step_phase:    フェイズごとの実行
// step_inst:     命令ごとの実行
// cstate:        制御状態信号
// running:       実行中を示すフラグ
// dbg_in:        デバッグ用の書込みデータ
// dbg_pc_ld:     デバッグ用のPCの書込みイネーブル
// dbg_ir_ld:     デバッグ用のIRの書込みイネーブル
// dbg_reg_ld:    デバッグ用のレジスタファイルの書込みイネーブル
// dbg_reg_addr:  デバッグ用のレジスタファイルのアドレス
// dbg_a_ld:      デバッグ用のAレジスタの書込みイネーブル
// dbg_b_ld:      デバッグ用のBレジスタの書込みイネーブル
// dbg_c_ld:      デバッグ用のCレジスタの書込みイネーブル
// dbg_mem_addr:  デバッグ用のメモリアドレス
// dbg_mem_read:  デバッグ用のメモリ読み出しイネーブル
// dbg_mem_write: デバッグ用のメモリ書込みイネーブル
// dbg_pc_out:    デバッグ用のPC出力
// dbg_ir_out:    デバッグ用のIR出力
// dbg_reg_out:   デバッグ用のレジスタファイル出力
// dbg_a_out:     デバッグ用のAレジスタ出力
// dbg_b_out:     デバッグ用のBレジスタ出力
// dbg_c_out:     デバッグ用のCレジスタ出力
// dbg_mem_out:   デバッグ用のメモリ出力

// module pc_selector(
// 	input [31:0] pc,
// 	input [31:0] creg,
// 	input pc_sel,
	
// 	output [31:0] pc_out);

// 	assign pc_out=pc_sel?creg:pc+4;

// endmodule // pc_selector
module pc_add(input [31:0] pc,
			input run,
			input running,
			input step_phase,
			input step_inst,
			input [3:0] cstate,
			output [31:0] pc_next);

	function [31:0] pc_n(input [3:0] cstate,
						input run,
						input step_phase,
						input step_inst,
						input [31:0] pc);
//		if(cstate==4'b0001&&(run||step_inst||step_phase))
//			pc_n=pc+4;
//		else
//			pc_n=pc;
		pc_n=pc+4;
	endfunction

	assign pc_next=pc_n(cstate,run,step_phase,step_inst,pc);
endmodule
module kappa3_light_core(input 	       clock,
			 input 	       clock2,
			 input 	       reset,

			 // 実行制御
			 input 	       run,
			 input 	       step_phase,
			 input 	       step_inst,

			 output [3:0]  cstate,
			 output        running,

			 // デバッグ関係
			 input [31:0]  dbg_in,
			 input 	       dbg_pc_ld,
			 input 	       dbg_ir_ld,
			 input 	       dbg_reg_ld,
			 input [4:0]   dbg_reg_addr,
			 input 	       dbg_a_ld,
			 input 	       dbg_b_ld,
			 input 	       dbg_c_ld,
			 input [31:0]  dbg_mem_addr,
			 input 	       dbg_mem_read,
			 input 	       dbg_mem_write,
			 output [31:0] dbg_pc_out,
			 output [31:0] dbg_ir_out,
			 output [31:0] dbg_reg_out,
			 output [31:0] dbg_a_out,
			 output [31:0] dbg_b_out,
			 output [31:0] dbg_c_out,
			 output [31:0] dbg_mem_out);

   // デバッグモードの信号
   wire 			       dbg_mode;
   assign dbg_mode = !running;

   // PC
   wire [31:0] 			pc_in;       // PC の書き込みデータ
   wire 			pc_ld;       // PC の書き込みイネーブル信号
   wire [31:0] 			pc;          // PC の値
   reg32 pc_inst(.clock(clock2),
		 .reset(reset),
		 .in(pc_in),
		 .ld(pc_ld),
		 .out(pc),
		 .dbg_mode(dbg_mode),
		 .dbg_in(dbg_in),
		 .dbg_ld(dbg_pc_ld));
   assign dbg_pc_out = pc;

   

   // メモリ
	wire mem_read;

   wire [31:0] 		 mem_addr;
   wire 		 mem_write;
   wire [31:0] 		 mem_wrdata;
   wire [3:0] 		 mem_wrbits;
   wire [31:0] 		 mem_rddata;
   memory mem_inst(.clock(clock),
		   .address(mem_addr),
		//    .read(1'b1),
			.read(mem_read),
		   .write(mem_write),
		   .wrdata(mem_wrdata),
		   .wrbits(mem_wrbits),
		   .rddata(mem_rddata),
		   .dbg_address(dbg_mem_addr),
		   .dbg_read(dbg_mem_read),
		   .dbg_write(dbg_mem_write),
		   .dbg_in(dbg_in));
//		   .dbg_out(dbg_mem_out));

	assign dbg_mem_out=mem_rddata;

	// IR
   wire [31:0] 		 ir_in;      // IR の書き込みデータ
   wire 		 ir_ld;      // IR の書き込みイネーブル信号
   wire [31:0] 		 ir;         // IRの値
   reg32 ir_inst(.clock(clock2),
		 .reset(reset),
		//  .in(ir_in),
		.in(mem_rddata),
		 .ld(ir_ld),
		 .out(ir),
		 .dbg_mode(dbg_mode),
		 .dbg_in(dbg_in),
		 .dbg_ld(dbg_ir_ld));
   assign dbg_ir_out = ir;

   // reg-file
   wire [4:0] 		 rs1_addr;     // rs1 のアドレス
   wire [4:0] 		 rs2_addr;     // rs2 のアドレス
   wire [4:0] 		 rd_addr;      // rd のアドレス
   wire [31:0] 		 rd_in;        // rd に書き込む値
   wire                  rd_ld;        // rd の書込みイネーブル信号
   wire [31:0] 		 rs1;          // rs1 の値
   wire [31:0] 		 rs2;          // rs2 の値
   regfile regfile_inst(.clock(clock2),
			.reset(reset),
			.rs1_addr(rs1_addr),
			.rs2_addr(rs2_addr),
			.rd_addr(rd_addr),
			.in(rd_in),
			.ld(rd_ld),
			.rs1_out(rs1),
			.rs2_out(rs2),
			.dbg_mode(dbg_mode),
			.dbg_in(dbg_in),
			.dbg_addr(dbg_reg_addr),
			.dbg_ld(dbg_reg_ld),
			.dbg_out(dbg_reg_out));

   // A-reg
   wire                  a_ld;         // A-reg の書込みイネーブル信号
   wire [31:0] 		 areg;         // A-reg の値
   reg32 areg_inst(.clock(clock2),
		   .reset(reset),
		   .in(rs1),
		   .ld(a_ld),
		   .out(areg),
		   .dbg_mode(dbg_mode),
		   .dbg_in(dbg_in),
		   .dbg_ld(dbg_a_ld));
   assign dbg_a_out = areg;

   // B-reg
   wire                  b_ld;         // B-reg の書込みイネーブル信号
   wire [31:0] 		 breg;         // B-reg の値
   reg32 breg_inst(.clock(clock2),
		   .reset(reset),
		   .in(rs2),
		   .ld(b_ld),
		   .out(breg),
		   .dbg_mode(dbg_mode),
		   .dbg_in(dbg_in),
		   .dbg_ld(dbg_b_ld));
   assign dbg_b_out = breg;

   // ALU
   wire [31:0] 		 alu_out;      // ALU の出力
   // 実際にはここに alu のインスタンス記述が入る．
   wire [31:0] in1;
   wire [31:0] in2;
   wire [3:0] alu_ctl;
   alu alu_inst(.in1(in1),
   				.in2(in2),
				.ctl(alu_ctl),
				.out(alu_out));

   // C-reg
   wire                  c_ld;         // C-reg の書込みイネーブル信号
   wire [31:0] 		 creg;         // C-reg の値
   reg32 creg_inst(.clock(clock2),
		   .reset(reset),
		   .in(alu_out),
		   .ld(c_ld),
		   .out(creg),
		   .dbg_mode(dbg_mode),
		   .dbg_in(dbg_in),
		   .dbg_ld(dbg_c_ld));
   assign dbg_c_out = creg;

   // running は実際には phasegen の出力を用いる．
   phasegen phasegen_inst(.clock(clock2), .reset(reset),
   			  .run(run), .step_phase(step_phase), .step_inst(step_inst),
   			  .cstate(cstate), .running(running));

   stconv stconv_inst(.in(breg),
   					  .ir(ir),
					  .out(mem_wrdata));

	wire [31:0] ldconvout;

	ldconv ldconv_inst(.in(mem_rddata),
						.ir(ir),
						.offset(mem_addr[1:0]),
						.out(ldconvout));

	wire pc_sel;
	// wire mem_read;
	wire mem_sel;
	wire [1:0] rd_sel;
	wire a_sel;
	wire b_sel;
	wire [31:0] imm;
	controller controller_inst(.cstate(cstate),
								.ir(ir),
								.addr(mem_addr),
								.alu_out(alu_out),
								.pc_sel(pc_sel),
								.pc_ld(pc_ld),
								.mem_sel(mem_sel),
								.mem_read(mem_read),
								.mem_write(mem_write),
								.mem_wrbits(mem_wrbits),
								.ir_ld(ir_ld),
								.rs1_addr(rs1_addr),
								.rs2_addr(rs2_addr),
								.rd_addr(rd_addr),
								.rd_sel(rd_sel),
								.rd_ld(rd_ld),
								.a_ld(a_ld),
								.b_ld(b_ld),
								.a_sel(a_sel),
								.b_sel(b_sel),
								.imm(imm),
								.alu_ctl(alu_ctl),
								.c_ld(c_ld));

	function [31:0] mem_selor(input [31:0] pc, input [31:0] creg, input mem_sel);
		case (mem_sel)
			1'b0: mem_selor=pc;
			1'b1: mem_selor=creg;
		endcase
	endfunction
	assign mem_addr=mem_selor(pc,creg,mem_sel);

	
	wire [31:0] pc_n;
	pc_add pc_add_inst(.pc(pc),
						.run(run),
						.running(running),
						.step_phase(step_phase),
						.step_inst(step_inst),
						.cstate(cstate),
						.pc_next(pc_n),
						);


	function [31:0] pc_selor(input [31:0] pc_next, input [31:0] creg, input pc_sel);	
		case (pc_sel)
			1'b0: pc_selor=pc_next;
			1'b1: pc_selor=creg;
		endcase
	endfunction
	assign pc_in=pc_selor(pc_n,creg,pc_sel);

	function [31:0] a_selor(input [31:0] areg,input [31:0] pc,input a_sel);
		case (a_sel)
			1'b0: a_selor=areg;
			1'b1: a_selor=pc;
		endcase
	endfunction
	assign in1=a_selor(areg,pc,a_sel);

	function [31:0] b_selor(input [31:0] breg,input [31:0] imm,input b_sel);
		case (b_sel)
			1'b0: b_selor=breg;
			1'b1: b_selor=imm;
		endcase
	endfunction
	assign in2=b_selor(breg,imm,b_sel);

	wire [31:0] csr_out;

	function [31:0] rd_selor(input [31:0] ldconvout,
							 input [31:0] pc,
							 input [31:0] creg,
							 input [31:0] csr_out,
							 input [1:0] rd_sel);
		case (rd_sel)
			2'b00: rd_selor=ldconvout;
			2'b01: rd_selor=pc;
			2'b10: rd_selor=creg;
			2'b11: rd_selor=csr_out;
		endcase
	endfunction
	assign rd_in=rd_selor(ldconvout,pc,creg,csr_out,rd_sel);

endmodule // kappa3_light_core
	
// endmodule