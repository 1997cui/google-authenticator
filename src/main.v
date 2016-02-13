`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:11:32 12/07/2015 
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
module main(
    input rst_in,
	 input clk,
	 input sync,
	 input EppAstb,
    input EppDstb,
    input EppWr,
    inout [7:0] EppDB,
    output EppWait,
    output [7:0] seg,
    output [3:0] an,
	 output [7:0] led
    );
	parameter freq=100000000;
	parameter chg_time=30;
	parameter debouncer_cycles=262143;
	//default key is "caaa aaaa aaaa aaaa"
	parameter secret=512'h10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
	
	wire rst;
	wire sha1_init, sha1_next, sha1_ready;
	wire [159:0] sha1_digest;
	wire [159:0] sample_input;
	wire [511:0] sha1_block;
	wire [23:0] fin_output;
	wire [23:0] sample_output;
	
	wire [31:0] sync_time;
	wire [63:0] current_time;
	
	debouncer #(.cycles (debouncer_cycles)) debouncer1(.btn (rst_in),.clk (clk), .ol (rst));
	
	super_display #(.freq (freq)) super_display1(.clk (clk), .rst (rst), .sel_in (4'b1111), .dat (fin_output[15:0]), 
	.sel (an[3:0]), .c (seg[7:0]));
	
	assign led[7:0] = fin_output[23:16];
	
	controller #(.secret (secret))controller1(
    .rst (rst), .clk (clk),
	 .sha1_init (sha1_init),.sha1_next (sha1_next), .sha1_block (sha1_block[511:0]), .sha1_ready (sha1_ready), .sha1_digest (sha1_digest),
	 .sample_ready (sample_ready), .sample_init (sample_init), .outer_sha1_digest (sample_input[159:0]), .sample_output(sample_output[23:0]),
	 .time_up (time_up), .current_time (current_time[63:0]), .fin_output (fin_output[23:0]));
	
	sha1_core sha1(.clk (clk), .reset_n (~rst), .init (sha1_init), .next (sha1_next), .block (sha1_block[511:0]),
	.ready (sha1_ready), 
	.digest (sha1_digest[159:0]));
	
	sample sample1(.clk (clk), .rst (rst), .init (sample_init), .sha1_digest (sample_input[159:0]), .code (sample_output[23:0]), .ready (sample_ready));
	
	
	IOExpansion IOExpansion1(.EppAstb (EppAstb), .EppDstb (EppDstb), .EppWr (EppWr), .EppDB (EppDB[7:0]),
	.Led (8'b1), .EppWait (EppWait), .dwOut (sync_time[31:0]), .dwIn (current_time[31:0]));
	
	time_int #(.freq (freq), .chg_time (chg_time))time_int1(.clk (clk), .rst (rst), .sync (sync), .sync_time (sync_time[31:0]), .current_time (current_time)
	,.time_up (time_up));

endmodule
