`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:21:47 12/07/2015 
// Design Name: 
// Module Name:    time_int 
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
module time_int(
    input clk,
    input rst,
    input sync,
    input [31:0] sync_time,
    output reg [63:0] current_time,
    output reg time_up
    );

		parameter freq=100000000;
		parameter chg_time=30;
		localparam cycle=freq*chg_time;
		
		integer counter;
	
		always @(posedge clk) begin
		if (rst) begin
			counter <= 0;
			if (~sync)
				current_time <= 0;
			else current_time <= {32'b0,sync_time[31:0]};
			time_up <= 1;
		end else begin
			counter <= counter + 1;
			time_up <= 0;
			if (counter == cycle) begin
				counter <= 0;
				current_time <= current_time + 1;
				time_up <= 1;
			end
		end
	end

endmodule
