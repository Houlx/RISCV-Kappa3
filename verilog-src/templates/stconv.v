
// @file stconv.v
// @breif stconv(ストアデータ変換器)
// @author Yusuke Matsunaga (松永 裕介)
//
// Copyright (C) 2019 Yusuke Matsunaga
// All rights reserved.
//
// [概要]
// ストア命令用のデータ変換を行う．
// wrbits が1のビットの部分のみ書き込みを行う．
// 具体的には以下の処理を行う．
//
// * B(byte) タイプ
//   in の下位8ビットを4つ複製する．
// * H(half word) タイプ
//   in の下位16ビットを2つ複製する．
// * W(word) タイプ
//   out は in をそのまま．
//
// B, H, W タイプの判別は IR レジスタの内容で行う．
//
// [入出力]
// in:     入力(32ビット)
// ir:     IRレジスタの値
// out:    出力(32ビット)
module stconv(input [31:0]      in,
	      input [31:0] 	ir,

	      output [31:0] out);

	// always @(*) begin
	// 	if (ir[6:0]==7'b0100011) begin
	// 		case (ir[14:12])
	// 			3'b000: out<={4{in[7:0]}};
	// 			3'b001: out<={2{in[15:0]}};
	// 			3'b010: out<=in;
	// 			default: begin
	// 			end
	// 		endcase
	// 	end
	// 	else out<=32'b0;
	// end

	function [31:0] stconvert(input [31:0] in,
								input [31:0] ir);
		if (ir[6:0]==7'b0100011) begin
			case (ir[14:12])
				3'b000: stconvert={4{in[7:0]}};
				3'b001: stconvert={2{in[15:0]}};
				3'b010: stconvert=in;
				default: begin
				end
			endcase
		end
		else stconvert=32'b0;
	endfunction

	assign out=stconvert(in,ir);

endmodule // stconv
