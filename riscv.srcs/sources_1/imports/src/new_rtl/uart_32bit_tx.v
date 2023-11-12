module uart_32bit_tx(
    input wire clk,
    input wire reset,
    input wire send_start,
    input wire [31:0] data_in,
    input wire one_byte,
    output wire tx,
    output reg data_end
);

// UART Instances
reg        byte_start;
reg [7:0]  send_data;
wire        send_ready;


wire tx_busy ;

wire baud_tick;
localparam CLK_FREQUENCY = 1000000 ;
localparam BAUD_RATE = 115200 ; 

uart_baud_tick_gen #(
		.CLK_FREQUENCY(CLK_FREQUENCY),
		.BAUD_RATE(BAUD_RATE),
		.OVERSAMPLING(1)
	) baud_tick_blk (
		.clk(clk),
		.enable(tx_busy),
		.tick(baud_tick)
	);

uart_tx uart_tx(
    .clk        (clk),
    .reset      (reset),
    .baud_tick(baud_tick),
    .tx(tx),
    .tx_start (byte_start),
    .tx_data   (send_data),
    .tx_busy   (tx_busy),
    .tx_ready  (send_ready)
);

// FSM States
localparam  IDLE       = 3'b000,
            SEND_BYTE1 = 3'b001,
            SEND_BYTE2 = 3'b010,
            SEND_BYTE3 = 3'b011,
            SEND_BYTE4 = 3'b100,
            DONE       = 3'b101;

reg [2:0] state;
reg [2:0] next_state;  

always @(posedge clk) begin
    if(reset) begin
        state <= IDLE;
    end
    else begin
        state <= next_state;
    end
end


always @(*) begin
    case(state)
        IDLE: begin
            send_data = 0;
            byte_start = 0;
            data_end = 0;
            if(send_start) next_state = SEND_BYTE1;
            else next_state = IDLE;
        end
        SEND_BYTE1: begin
            byte_start = 1;
            send_data = data_in[7:0];
            data_end = 0;
            if(send_ready) begin
                if(one_byte) next_state = DONE;
                else next_state = SEND_BYTE2;
            end
            else next_state = SEND_BYTE1;
        end
        SEND_BYTE2: begin
            byte_start = 1;
            send_data = data_in[15:8];
            data_end = 0;
            if(send_ready) next_state = SEND_BYTE3;
            else next_state = SEND_BYTE2;
        end
        SEND_BYTE3: begin
            byte_start = 1;
            send_data = data_in[23:16];
            data_end = 0;
            if(send_ready) next_state = SEND_BYTE4;
            else next_state = SEND_BYTE3;
        end
        SEND_BYTE4: begin
            byte_start = 1;
            send_data = data_in[31:24];
            data_end = 0;
            if(send_ready) next_state = DONE;
            else next_state = SEND_BYTE4;
        end
        DONE: begin
            data_end = 1;
            send_data = 0;
            byte_start = 0;
            next_state = IDLE;
        end
        default: begin
            next_state = IDLE;
            send_data = 0;
            byte_start = 0;
            data_end = 0;
        end
    endcase
end

endmodule
