
// @file decode_7seg.v
// @breif 7SEG-LED のデコーダ回路
// @author Yusuke Matsunaga (松永 裕介)
//
// Copyright (C) 2019 Yusuke Matsunaga
// All rights reserved.
//
// [概要]
// 7SEG-LED に 0-9, A-F のパタンを表示するためのデコーダ
//
// [入出力]
// in:  入力(4ビット)
// out: 出力(8ビット)
module decode_7seg(input [3:0] in,
		   output [7:0] out);
			
		function [7:0] decoder(input [3:0] in);
		begin
			case(in)
				4'b0000:decoder=8'b11111100;
				4'b0001:decoder=8'b01100000;
				4'b0010:decoder=8'b11011010;
				4'b0011:decoder=8'b11110010;
				4'b0100:decoder=8'b01100110;
				4'b0101:decoder=8'b10110110;
				4'b0110:decoder=8'b10111110;
				4'b0111:decoder=8'b11100000;
				4'b1000:decoder=8'b11111110;
				4'b1001:decoder=8'b11110110;
				4'b1010:decoder=8'b11101110;
				4'b1011:decoder=8'b00111110;
				4'b1100:decoder=8'b00011010;
				4'b1101:decoder=8'b01111010;
				4'b1110:decoder=8'b10011110;
				4'b1111:decoder=8'b10001110;
				default:decoder=8'b11111100;
			endcase
		end
		endfunction
		
		assign out=decoder(in);

endmodule // decode_7seg
