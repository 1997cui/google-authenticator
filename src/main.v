`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Tianyi Cui
// 
// Create Date:    15:14:54 11/30/2015 
// Design Name: 
// Module Name:    main 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: Google Auth 
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
	 output reg [7:0] led
    );
	
	parameter freq=100000000;
	parameter chg_time=30;
	parameter cycles=262143;
	localparam cycle=freq*chg_time;
	
	localparam IDLE=4'b0000;
	localparam READY1=4'b0001;
	localparam BUSY1=4'b0010;
	localparam READY2=4'b0011;
	localparam BUSY2=4'b0100;
	localparam READY3=4'b0101;
	localparam BUSY3=4'b0110;
	localparam READY4=4'b0111;
	localparam BUSY4=4'b1000;
	localparam OUT=4'b1100;
	localparam READY5=4'b1101;
	localparam BUSY5=4'b1111;
	
	parameter secret=512'h8a6592a32ec8b890b18050a07f721e605edb6cf70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
	parameter ipad=  512'h36363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636;
   parameter opad=  512'h5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c;
	
	integer counter;
	reg [63:0] current_time;
	
	wire rst;
	
	reg [3:0] status1;
	reg [3:0] next_status1;
	
	reg sha1_init,sha1_next;
	reg [511:0] sha1_block;
	reg [15:0] fin_output;
	wire [23:0] sample_output;
	wire [159:0] sha1_digest;
	reg [159:0] inner_sha1_digest;
	reg [159:0] outer_sha1_digest;
	wire sha1_ready,sha1_digest_valid;
	reg time_up;
	wire sample_ready;
	reg sample_init;
	wire [31:0] sync_time;
	
	debouncer #(.cycles (cycles)) debouncer1(.btn (rst_in),.clk (clk), .ol (rst));
	
	super_display #(.freq (freq)) super_display1(.clk (clk), .rst (rst), .sel_in (4'b1111), .dat (fin_output[15:0]), 
	.sel (an[3:0]), .c (seg[7:0]));
	
	sha1_core sha1(.clk (clk), .reset_n (~rst), .init (sha1_init), .next (sha1_next), .block (sha1_block[511:0]),
	.ready (sha1_ready), 
	.digest (sha1_digest[159:0]), .digest_valid (sha1_digest_valid));
	
	sample sample1(.clk (clk), .rst (rst), .init (sample_init), .sha1_digest (outer_sha1_digest[159:0]), .code (sample_output[23:0]), .ready (sample_ready));
	
	
	IOExpansion IOExpansion1(.EppAstb (EppAstb), .EppDstb (EppDstb), .EppWr (EppWr), .EppDB (EppDB[7:0]),
	.Led (8'b1), .EppWait (EppWait), .dwOut (sync_time[31:0]), .dwIn (current_time[31:0]));
	
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

	always @(posedge clk) begin
		if (rst) status1 <= IDLE;
		else status1 <= next_status1;
	end

	always @(*) begin
		case (status1)
			IDLE: begin
				if (time_up) begin
					next_status1 = READY1;
				end else next_status1 = IDLE;
			end
			READY1: begin
				next_status1 = BUSY1;
			end
			BUSY1: begin
				if (sha1_ready) begin 
					next_status1 = READY2;
				end else next_status1 = BUSY1;
			end
			READY2: begin
				next_status1 = BUSY2;
			end
			BUSY2: begin
				if (sha1_ready) begin
					next_status1 = READY3;
				end else next_status1 = BUSY2;
			end
			READY3: begin
				next_status1 = BUSY3;
			end
			BUSY3: begin
				if (sha1_ready) next_status1 = READY4;
				else next_status1 = BUSY3;
			end
			READY4: begin
				next_status1 = BUSY4;
			end
			BUSY4: begin
				if (sha1_ready) next_status1 = READY5;
				else next_status1 = BUSY4;
			end
			READY5: begin
				next_status1 = BUSY5;
			end
			BUSY5: begin
				if (sample_ready) next_status1 = OUT;
				else next_status1 = BUSY5;
			end
			OUT: begin
				next_status1 = IDLE;
			end
			default: next_status1=IDLE;
		endcase
	end
	
	always @(posedge clk) begin
		if (rst) begin
			sha1_init <= 0;
			sha1_next <= 0;
			sha1_block[511:0] <= 512'b0;
			{led[7:0],fin_output[15:0]} <= 24'b0;
		end else begin
			case (next_status1)
				IDLE: begin
					sha1_init <= 0;
					sha1_next <= 0;
				end
				READY1: begin
					/*sha1_block[511:432] <= secret;
					sha1_block[431:400] <= current_time[31:0];
					sha1_block[399] <= 1;
					sha1_block[63:0] <= 64'd112;
					sha1_block[398:64] <= 335'b0;*/
					sha1_block[511:0] <= (secret[511:0] ^ ipad[511:0]);
					sha1_init <= 1;
				end
				BUSY1: begin
					sha1_init <= 0;
				end
				READY2: begin
					//fin_output[15:0] = sha1_digest[15:0];
					sha1_next <= 1;
					sha1_block[511:448] <= current_time[63:0];
					sha1_block[447] <= 1;
					sha1_block[446:64] <= 0;
					sha1_block[63:0] <= 64'd576;
					//$display("final output: 0x%4x", fin_output);
					$display("step 1.1 block data: 0x%0128x", sha1_block);
					$display("step 1.1 finished: sha1 digest: 0x%040x", sha1_digest);
				end
				BUSY2: begin
					sha1_next <= 0;
				end
				READY3: begin
					$display("step 1.2 block data: 0x%0128x", sha1_block);
					$display("Inner hash complete!");
					$display("Inner digest: 0x%40x", sha1_digest);
					inner_sha1_digest[159:0] <= sha1_digest[159:0]; 
					sha1_init <= 1;
					sha1_block[511:0] <= (secret[511:0] ^ opad[511:0]);
				end
				BUSY3: begin
					sha1_init <= 0;
				end
				READY4: begin
					$display("step 2.1 block data: 0x%0128x", sha1_block);
					$display("step 2.1 finished: sha1 digest: 0x%040x", sha1_digest);
					sha1_next <= 1;
					sha1_block[511:352] <= inner_sha1_digest[159:0];
					sha1_block[351] <= 1'b1;
					sha1_block[63:0] <= 64'd672;
					sha1_block[350:64] <= 0;
				end
				BUSY4: begin
					sha1_next <= 0;
				end
				READY5: begin
					outer_sha1_digest[159:0] <= sha1_digest[159:0]; 
					sample_init <= 1;
					//{led[7:0],fin_output[15:0]} <= sample_output[23:0];
					$display("step 2.2 block data: 0x%0128x", sha1_block);
					$display("Outer hash complete!");
					$display("Final digest: 0x%40x", sha1_digest);
					//$display("Final output: %0d%0d%0d%0d%0d%0d", sample_output[23:20], 
					//sample_output[19:16], sample_output[15:12], sample_output[11:8], sample_output[7:4], sample_output[3:0]);
				end
				BUSY5: begin
					sample_init <= 0;
				end
				OUT: begin
						{led[7:0],fin_output[15:0]} <= sample_output[23:0];
						$display("Final output: %0d%0d%0d%0d%0d%0d", sample_output[23:20], 
						sample_output[19:16], sample_output[15:12], sample_output[11:8], sample_output[7:4], sample_output[3:0]);
						$display("================================");
				end
			endcase
		end
	end

endmodule
