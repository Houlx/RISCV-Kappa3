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

		pc_n=pc+4;
	endfunction

	assign pc_next=pc_n(cstate,run,step_phase,step_inst,pc);
endmodule