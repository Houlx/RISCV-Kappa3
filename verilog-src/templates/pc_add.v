module pc_add(input [31:0] pc,
			output [31:0] pc_next);

	function [31:0] pc_n(input [31:0] pc);
		pc_n=pc+4;
	endfunction

	assign pc_next=pc_n(pc);
endmodule