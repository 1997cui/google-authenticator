`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:30:27 11/02/2015 
// Design Name: 
// Module Name:    main 
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
module super_display(
    input clk,
    input rst,
	 input [3:0] sel_in,
	 input [15:0] dat,
    output [3:0] sel,
    output [7:0] c
    );
	 //reg [15:0] data;
	 integer counter;
	 reg [3:0] temp_data;
	 reg [3:0] temp_sel;
	 reg [1:0] state;
	 parameter freq=10000000;
	 localparam bond=freq/1000;
	always @(posedge clk)
	begin
		if (rst) begin
			counter<=0;
			state <= 0;
			//data[15:0] <= 16'h1034;
		end
		else begin
			counter <= counter+1'b1;
			if (counter == bond) begin
				counter <= 0;
				state <= state + 2'b1;
			end
			
		end
	end
	
	always @(*) begin
		case (state[1:0])
			2'b00: begin temp_sel[3:0] <= 4'b1110; temp_data[3:0] <= dat[3:0]; end
			2'b01: begin temp_sel[3:0] <= 4'b1101; temp_data[3:0] <= dat[7:4]; end
			3'b10: begin temp_sel[3:0] <= 4'b1011; temp_data[3:0] <= dat[11:8]; end
			4'b11: begin temp_sel[3:0] <= 4'b0111; temp_data[3:0] <= dat[15:12]; end
		endcase
	end
	assign sel[3:0] = temp_sel[3:0] | ~sel_in[3:0];
	display display1(.d (temp_data[3:0]), .c (c[7:0]));
endmodule
