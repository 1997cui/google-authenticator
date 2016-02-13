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
module controller(
    input rst,
	 input clk,
	 output reg sha1_init,
	 output reg sha1_next,
	 output reg [511:0] sha1_block,
	 input wire sha1_ready,
	 input wire [159:0] sha1_digest,
	 input wire sample_ready,
	 output reg sample_init,
	 output reg [159:0] outer_sha1_digest,
	 input wire [23:0] sample_output,
	 input time_up,
	 input [63:0] current_time,
	 output reg [23:0] fin_output
    );
	
	//parameter freq=100000000;
	//parameter chg_time=30;
	//localparam cycle=freq*chg_time;
	
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
	
	parameter secret=	512'h10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
	localparam ipad=  512'h36363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636;
   localparam opad=  512'h5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c;
	

	reg [3:0] status1;
	reg [3:0] next_status1;
	reg [159:0] inner_sha1_digest;
	


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
			fin_output[23:0] <= 24'b0;
		end else begin
			case (next_status1)
				IDLE: begin
					sha1_init <= 0;
					sha1_next <= 0;
				end
				READY1: begin
					sha1_block[511:0] <= (secret[511:0] ^ ipad[511:0]);
					sha1_init <= 1;
				end
				BUSY1: begin
					sha1_init <= 0;
				end
				READY2: begin
					sha1_next <= 1;
					sha1_block[511:448] <= current_time[63:0];
					sha1_block[447] <= 1;
					sha1_block[446:64] <= 0;
					sha1_block[63:0] <= 64'd576;
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
					$display("step 2.2 block data: 0x%0128x", sha1_block);
					$display("Outer hash complete!");
					$display("Final digest: 0x%40x", sha1_digest);
				end
				BUSY5: begin
					sample_init <= 0;
				end
				OUT: begin
						fin_output[23:0] <= sample_output[23:0];
						$display("Final output: %0d%0d%0d%0d%0d%0d", sample_output[23:20], 
						sample_output[19:16], sample_output[15:12], sample_output[11:8], sample_output[7:4], sample_output[3:0]);
						$display("================================");
				end
			endcase
		end
	end

endmodule
