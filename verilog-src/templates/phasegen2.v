
// @file phasegen.v
// @breif フェーズジェ��?レータ
// @author Yusuke Matsunaga (�?�永 裕介)
//
// Copyright (C) 2019 Yusuke Matsunaga
// All rights reserved.
//
// [概��?]
// Generate the command phase.
//
// cstate = {cs_wb, cs_ex, cs_de, cs_if}
//, only one bit is always 1.
// cs_wb = cstate [3], cs_if = cstate [0]
//.Note that it is 
// The meaning of each bit is as follows.
// cs_if: IF phase
// cs_de: DE phase
// cs_ex: EX phase
// cs_wb: WB phase
//
// [input / output]
// clock: Clock signal (rising edge)
// reset: reset signal (0 resets)
// run: start running
// step_phase: 1 phase execution
// step_inst: execute one instruction
// cstate: Bit vector representing the instruction execution phase
// running: A signal that is running
module phasegen(input clock,
		input 	     reset,
		input 	     run,
		input 	     step_phase,
		input 	     step_inst,
		output    [3:0] cstate,
		output   reg   running);
reg [3:0] phase;
reg [1:0] istate;
// internal state
// STOP = 00
// RUN = 01
// STEP_inst = 10
// STEP_phase = 11
function [3:0] next(input [3:0] phase);
	case(phase)
		4'b0001:next=4'b0010;
		4'b0010:next=4'b0100;
		4'b0100:next=4'b1000;
		4'b1000:next=4'b0001;
	endcase
endfunction

always@(posedge clock or negedge reset)
begin
    if (!reset) begin
    phase <= 4'b0001;
    istate <= 2'b00;
    end
    else begin
    case(istate)
    2'b00 : begin  //stop
            if(run) istate = 2'b01; 
            else if(step_phase) istate = 2'b11;
            else if(step_inst) istate = 2'b10;
            else istate = 2'b00;
            end
    2'b01 : begin  //run
            if(run) istate = 2'b00;
            else begin 
                    istate = 2'b01; 
//                    phase <= phase << 1;
							phase=next(phase);
                 end
            end
    2'b10 : begin  //step_inst
            if(phase == 4'b1000)
            begin
            phase = 4'b0001;
            istate = 2'b00;
            end 
            else begin
            phase = phase<<1;
            istate = 2'b10;
            end
            end
    2'b11 : begin //step_phase
            phase=next(phase);
            istate = 2'b00;
            end
    endcase 
    
 if (istate != 2'b00) begin
    running <= 1'b1;
    end
    else begin
        running <= 1'b0;
        end
    end  
end
 
assign cstate = phase[3:0];
endmodule // phasegen
