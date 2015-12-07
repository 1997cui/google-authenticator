`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:58:57 11/16/2015 
// Design Name: 
// Module Name:    debouncer 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module debouncer(
    input btn,
    input clk,
    output ol,
    output op
    );
	 reg [17:0] cnt;
	 reg temp_ol=0;
	 reg temp_op=0;
	 parameter cycles=262143;
	 assign ol = temp_ol;
	 assign op = temp_op;
	 
	always @(posedge clk)
	begin
		temp_op <= 0;
		if (btn != ol) cnt <= cnt + 2'b1;
		else cnt <= 0;
		if (cnt == cycles) begin
			temp_ol <= btn;
			if (ol == 0) temp_op <= 1;
		end
	end

endmodule
