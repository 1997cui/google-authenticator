`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   23:08:17 12/05/2015
// Design Name:   sample
// Module Name:   D:/verilog/final/test_sample.v
// Project Name:  final
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: sample
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test_sample;

	// Inputs
	reg clk;
	reg init;
	reg rst;
	reg [159:0] sha1_digest;

	// Outputs
	wire [23:0] code;
	wire ready;

	// Instantiate the Unit Under Test (UUT)
	sample uut (
		.clk(clk), 
		.init(init), 
		.rst(rst), 
		.sha1_digest(sha1_digest), 
		.code(code), 
		.ready(ready)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		init = 0;
		rst = 0;
		sha1_digest = 160'h0e6921efd6b0ee7cefd925b080a3dc19acc69fd1;

		// Wait 100 ns for global reset to finish
		#20;
		rst = 1;
		#20;
		rst = 0;
		init = 1;
		#20;
		init = 0;
		#1000;
		$finish;
        
		// Add stimulus here

	end
   
	always begin
		#5;
		clk = ~clk;
	end
endmodule

