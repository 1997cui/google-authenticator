`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:05:01 12/05/2015 
// Design Name: 
// Module Name:    sample 
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
module sample(
	 input clk,
	 input init,
	 input rst,
    input [159:0] sha1_digest,
    output reg [23:0] code,
	 output reg ready
    );
	
	reg [7:0] byte_array [19:0];
	
	reg [31:0] hex_code;
	reg [2:0] status,next_status;
	localparam IDLE=3'b000;
	localparam READY1=3'b001;
	localparam READY2=3'b010;
	localparam BUSY=3'b011;
	integer counter;
	
	//assign code[23:0] = hex_code[23:0];
	/*always @(*) begin
		$display("Start to sample: 0x%40x", sha1_digest);
		ready = 0;
		byte_array[0] = sha1_digest[7:0];
		byte_array[1] = sha1_digest[15:8];
		byte_array[2] = sha1_digest[23:16];
		byte_array[3] = sha1_digest[31:24];
		byte_array[4] = sha1_digest[39:32];
		byte_array[5] = sha1_digest[47:40];
		byte_array[6] = sha1_digest[55:48];
		byte_array[7] = sha1_digest[63:56];
		byte_array[8] = sha1_digest[71:64];
		byte_array[9] = sha1_digest[79:72];
		byte_array[10] = sha1_digest[87:80];
		byte_array[11] = sha1_digest[95:88];
		byte_array[12] = sha1_digest[103:96];
		byte_array[13] = sha1_digest[111:104];
		byte_array[14] = sha1_digest[119:112];
		byte_array[15] = sha1_digest[127:120];
		byte_array[16] = sha1_digest[135:128];
		byte_array[17] = sha1_digest[143:136];
		byte_array[18] = sha1_digest[151:144];
		byte_array[19] = sha1_digest[159:152];
		
		$display("offset: %d", byte_array[0] & 8'h0f);
		
		hex_code[7:0] = byte_array[8'd16 - (byte_array[0] & 8'h0f)];
		hex_code[15:8] = byte_array[8'd17 - (byte_array[0] & 8'h0f)];
		hex_code[23:16] = byte_array[8'd18 - (byte_array[0] & 8'h0f)];
		hex_code[31:24] = byte_array[8'd19 - (byte_array[0] & 8'h0f)];
		hex_code[31] = 1'b0;
		$display("Hex code finished: 0x%08x", hex_code);
		code=24'b0;
		#50000000;
		for (i=31;i>=0;i=i-1) begin
			if (code[3:0] >= 5) code[3:0] = code[3:0] + 4'd3;
			if (code[7:4] >= 5) code[7:4] = code[7:4] + 4'd3;
			if (code[11:8] >= 5) code[11:8] = code[11:8] + 4'd3;
			if (code[15:12] >= 5) code[15:12] = code[15:12] + 4'd3;
			if (code[19:16] >= 5) code[19:16] = code[19:16] + 4'd3;
			if (code[23:20] >= 5) code[23:20] = code[23:20] + 4'd3;
			
			

			code[23:0] = {code[22:0], hex_code[i]};
			
		end
		
		$display("Decimal code finished: %d%d%d%d%d%d", code[23:20],code[19:16],code[15:12],code[11:8],
		code[7:4],code[3:0]);
		ready = 1;
	end*/

	always @(posedge clk) begin
		if (rst) status <= IDLE;
		else status <= next_status;
	end
	
	always @(*) begin
		case (status)
			IDLE: begin
				if (init == 1) next_status <= READY1;
				else next_status <= IDLE;
			end
			READY1: begin 
				next_status <= READY2;
			end
			READY2: begin
				next_status <= BUSY;
			end
			BUSY: begin
				if (counter == -1) begin
					next_status <= IDLE;
					$display("Decimal code finished: %d%d%d%d%d%d", code[23:20],code[19:16],code[15:12],code[11:8],code[7:4],code[3:0]);
				end else next_status <= BUSY;
			end
			default: next_status <= IDLE;
		endcase
	end
	
	always @(posedge clk) begin
		if (rst) ready <= 0;
		else begin
			case (next_status)
				IDLE: begin 
					if (init == 1) ready <= 0;
					else ready <= 1;
				end
				READY1: begin 
					ready <= 0;
					counter <= 31;
					code[23:0] = 24'b0;
					
					byte_array[0] <= sha1_digest[7:0];
					byte_array[1] <= sha1_digest[15:8];
					byte_array[2] <= sha1_digest[23:16];
					byte_array[3] <= sha1_digest[31:24];
					byte_array[4] <= sha1_digest[39:32];
					byte_array[5] <= sha1_digest[47:40];
					byte_array[6] <= sha1_digest[55:48];
					byte_array[7] <= sha1_digest[63:56];
					byte_array[8] <= sha1_digest[71:64];
					byte_array[9] <= sha1_digest[79:72];
					byte_array[10] <= sha1_digest[87:80];
					byte_array[11] <= sha1_digest[95:88];
					byte_array[12] <= sha1_digest[103:96];
					byte_array[13] <= sha1_digest[111:104];
					byte_array[14] <= sha1_digest[119:112];
					byte_array[15] <= sha1_digest[127:120];
					byte_array[16] <= sha1_digest[135:128];
					byte_array[17] <= sha1_digest[143:136];
					byte_array[18] <= sha1_digest[151:144];
					byte_array[19] <= sha1_digest[159:152];
				
				end
				
				READY2: begin
					$display("offset: %d", byte_array[0] & 8'h0f);
					ready <= 0;
					hex_code[7:0] <= byte_array[8'd16 - (byte_array[0] & 8'h0f)];
					hex_code[15:8] <= byte_array[8'd17 - (byte_array[0] & 8'h0f)];
					hex_code[23:16] <= byte_array[8'd18 - (byte_array[0] & 8'h0f)];
					hex_code[30:24] <= byte_array[8'd19 - (byte_array[0] & 8'h0f)][7:0];
					hex_code[31] <= 1'b0;
				end
				BUSY: begin
					ready <= 0;
					counter <= counter - 1;
					if (code[3:0] >= 5) code[3:0] = code[3:0] + 4'd3;
					if (code[7:4] >= 5) code[7:4] = code[7:4] + 4'd3;
					if (code[11:8] >= 5) code[11:8] = code[11:8] + 4'd3;
					if (code[15:12] >= 5) code[15:12] = code[15:12] + 4'd3;
					if (code[19:16] >= 5) code[19:16] = code[19:16] + 4'd3;
					if (code[23:20] >= 5) code[23:20] = code[23:20] + 4'd3;
					code[23:1] = code[22:0];
					code[0] = hex_code[counter];
				end
			endcase
		end
	end
	
endmodule
