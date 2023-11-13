`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.07.2019 15:11:28
// Design Name: 
// Module Name: uart_tx
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module uart_tx
(
	input clk,
	input reset,
	input baud_tick,
	input tx_start,
	input [7:0] tx_data,
	output reg tx,
	output reg tx_busy,
	output reg tx_ready
);

	localparam TX_IDLE  = 2'b00;
	localparam TX_START = 2'b01;
	localparam TX_SEND  = 2'b10;
	localparam TX_STOP  = 2'b11;

	reg [1:0] state = TX_IDLE, state_next;
	reg [2:0] counter = 3'd0, counter_next;
    reg [7:0] tx_data_reg;
    
    always @(posedge clk) begin
        if (reset)
            tx_data_reg <= 'd0;
        else if (state == TX_IDLE && tx_start)
            tx_data_reg <= tx_data;
    end

	always @(*) begin
		tx = 1'b1;
		tx_busy = 1'b1;
		tx_ready = 1'b0;
		state_next = state;
		counter_next = counter;

		case (state)
		TX_IDLE: begin
			tx_busy = 1'b0;
			state_next = (tx_start) ? TX_START : TX_IDLE;
		end
		TX_START: begin
			tx = 1'b0;
			state_next = (baud_tick) ? TX_SEND : TX_START;
			counter_next = 'd0;
		end
		TX_SEND: begin
			tx = tx_data_reg[counter];
			if (baud_tick) begin
				state_next = (counter == 'd7) ? TX_STOP : TX_SEND;
				counter_next = counter + 'd1;
			end
		end
		TX_STOP: begin 
			tx_ready = 1'b1;
			state_next = (baud_tick) ? TX_IDLE : TX_STOP;
		end
		endcase
	end

	always @(posedge clk) begin
		if (reset) begin
			state <= TX_IDLE;
			counter <= 'd0;
		end else begin
			state <= state_next;
			counter <= counter_next;
		end
	end

endmodule