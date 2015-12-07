`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   21:42:11 12/04/2015
// Design Name:   main
// Module Name:   D:/verilog/final/test_main.v
// Project Name:  final
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: main
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test_main;

	// Inputs
	reg rst_in;
	reg clk;
	reg sync;
	// Outputs
	wire [7:0] seg;
	wire [3:0] an;

	// Instantiate the Unit Under Test (UUT)
	main #(.freq (50), .cycles (2)) uut (
		.rst_in(rst_in), 
		.clk(clk), 
		.seg(seg), 
		.sync (sync),
		.an(an)
	);

	initial begin
		// Initialize Inputs
		rst_in = 0;
		clk = 0;
		sync = 0;
		// Wait 100 ns for global reset to finish
		#50000000;
      
		rst_in = 1;
		#90000000;
		rst_in=0;
		// Add stimulus here

	end
   
	always begin
		clk = ~clk;
		#10000000;
	end
endmodule

