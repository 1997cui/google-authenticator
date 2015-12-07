`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:27:15 11/02/2015 
// Design Name: 
// Module Name:    display 
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
module display(
    input 		[3:0] d,
    output reg [7:0] c
    );
always@(*)
begin
	case(d[3:0])
		4'h0: c	= 8'b0000_0011;
		4'h1: c  = 8'b1001_1111;
		4'h2: c	= 8'b0010_0101;
		4'h3:	c	= 8'b0000_1101;
		4'h4:	c	= 8'b1001_1001;
		4'h5: c	= 8'b0100_1001;
		4'h6:	c	= 8'b0100_0001;
		4'h7:	c	= 8'b0001_1111;
		4'h8:	c	= 8'b0000_0001;
		4'h9: c	= 8'b0000_1001;
		4'ha:	c	= 8'b0001_0001;
		4'hb:	c	= 8'b1100_0001;
		4'hc: c	= 8'b0110_0011;
		4'hd:	c	= 8'b1000_0101;
		4'he:	c	= 8'b0110_0001;
		4'hf:	c	= 8'b0111_0001;
		default: c = 8'b0000_0000;
	endcase
end

endmodule
