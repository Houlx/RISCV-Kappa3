
// @file ldconv.v
// @breif ldconv(ロードデータ変換器)
// @author Yusuke Matsunaga (松永 裕介)
//
// Copyright (C) 2019 Yusuke Matsunaga
// All rights reserved.
//
// [概要]
// ロードのデータタイプに応じてデータを変換する．
// 具体的には以下の処理を行う．
//
// * B(byte) タイプ
//   オフセットに応じたバイトを取り出し，符号拡張を行う．
// * BU(byte unsigned) タイプ
//   オフセットに応じたバイトを取り出し，上位に0を詰める．
// * H(half word) タイプ
//   オフセットに応じたハーフワード(16ビット)を取り出し，符号拡張を行う．
// * HU(half word unsigned) タイプ
//   オフセットに応じたハーフワード(16ビット)を取り出し，上位に0を詰める．
// * W(word) タイプ
//   そのままの値を返す．
//
// B, BU, H, HU, W タイプの判別は IR レジスタの内容で行う．
//
// [入出力]
// in:     入力(32ビット)
// ir:     IRレジスタの値
// offset: アドレスオフセット
// out:    出力(32ビット)
module ldconv(input [31:0]      in,
	      input [31:0] 	ir,
	      input [1:0] 	offset,

	      output [31:0] out);

		wire [7:0] onebyte;
		wire [15:0] half_word;

		function [7:0] getbyte(input [31:0] in, input [1:0] offset);
		case (offset)
			2'b00: getbyte=in[31:24];
			2'b01: getbyte=in[23:16];
			2'b10: getbyte=in[15:8];
			2'b11: getbyte=in[7:0];
			default: begin
			end
		endcase
		endfunction

		function [15:0] gethalfword(input [31:0] in, input [1:0] offset);
		case (offset)
			2'b00: gethalfword=in[31:16];
			// 2'b01: gethalfword=in[23:8];
			2'b10: gethalfword=in[15:0];
			default:begin
			end
		endcase
		endfunction

		assign onebyte=getbyte(in,offset);
		assign half_word=gethalfword(in,offset);

		function [31:0] ldconvert(input [31:0] in,
									input [31:0] ir);
			if(ir[6:0]==7'b0000011)begin
				case(ir[14:12])
					3'b000: ldconvert={{24{onebyte[7]}},{onebyte}};
					3'b001: ldconvert={{16{half_word[15]}},{half_word}};
					3'b010: ldconvert=in;
					3'b100: ldconvert={{24'b0},{onebyte}};
					3'b101: ldconvert={{16'b0},{half_word}};
					default:begin
					end
				endcase
			end
		endfunction

		assign out=ldconvert(in,ir);


endmodule // ldconv
