module uart_32bit_rx (
    input wire clk, reset,
    input wire rx,
    input wire one_byte,
    output reg [31:0] data_out,
    output reg data_end
);

// UART Instance
wire [7:0] recv_data;
wire       recv_ready;  

uart_sm_rx uart_rx (
    .clk      ( clk ),
    .reset    ( reset ),
    .rx       ( rx ),
    .byte_out ( recv_data ),
    .byte_end ( recv_ready )
);

// FSM States
localparam  IDLE       = 4'b0000,
            RECV_BYTE1 = 4'b0001,
            SAVE_BYTE1 = 4'b0010,
            RECV_BYTE2 = 4'b0011,
            SAVE_BYTE2 = 4'b0100,
            RECV_BYTE3 = 4'b0101,
            SAVE_BYTE3 = 4'b0110,
            RECV_BYTE4 = 4'b0111,
            SAVE_BYTE4 = 4'b1000,
            DONE       = 4'b1001;

reg [3:0] state;
reg [3:0] next_state ;  

always @(posedge clk) begin
    if(reset) begin
        state <= IDLE;
    end
    else begin
        state <= next_state;
    end
end

reg       rst_data;
reg       save;
reg [1:0] save_ctrl;

reg [2:0] i;

always @(posedge clk) begin
    if( reset || rst_data ) begin
        data_out <= 'b0;
    end
    else begin
        data_out <= data_out;
        if(save) begin
            for( i = 0; i <= 'b11; i=i+1'b1 ) begin
                if( save_ctrl == i[1:0] ) data_out[i*8+:8] <= recv_data;
            end
        end
    end
end

always @(*) begin
    case(state)
        IDLE: begin
            rst_data = 1;
            save = 0;
            save_ctrl = 0;
            data_end = 0;
            next_state = RECV_BYTE1;
        end
        RECV_BYTE1: begin
            rst_data = 0;
            save = 0;
            save_ctrl = 0;
            data_end = 0;
            if( recv_ready ) next_state = SAVE_BYTE1;
            else next_state = RECV_BYTE1;
        end
        SAVE_BYTE1: begin
            save = 1;
            save_ctrl = 0;
            rst_data = 0;
            data_end = 0;
            if( one_byte ) next_state = DONE;
            else next_state = RECV_BYTE2;
        end
        RECV_BYTE2: begin
            rst_data = 0;
            save = 0;
            save_ctrl = 0;
            data_end = 0;
            if( recv_ready ) next_state = SAVE_BYTE2;
            else next_state = RECV_BYTE2;
        end
        SAVE_BYTE2: begin
            save = 1;
            save_ctrl = 1;
            rst_data = 0;
            data_end = 0;
            next_state = RECV_BYTE3;
        end
        RECV_BYTE3: begin
            rst_data = 0;
            save = 0;
            save_ctrl = 0;
            data_end = 0;
            if( recv_ready ) next_state = SAVE_BYTE3;
            else next_state = RECV_BYTE3;
        end
        SAVE_BYTE3: begin
            save = 1;
            save_ctrl = 2;
            rst_data = 0;
            data_end = 0;
            next_state = RECV_BYTE4;
        end
        RECV_BYTE4: begin
            rst_data = 0;
            save = 0;
            save_ctrl = 0;
            data_end = 0;
            if( recv_ready ) next_state = SAVE_BYTE4;
            else next_state = RECV_BYTE4;
        end
        SAVE_BYTE4: begin
            save = 1;
            save_ctrl = 3;
            rst_data = 0;
            data_end = 0;
            next_state = DONE;
        end
        DONE: begin
            data_end = 1;
            rst_data = 0;
            save = 0;
            save_ctrl = 0;
            next_state = IDLE;
        end
        default: begin
            next_state = IDLE;
            rst_data = 0;
            save = 0;
            save_ctrl = 0;
            data_end = 0;
        end
    endcase
end

endmodule
