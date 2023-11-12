module com_controller(
    input wire clk,reset,
    
    // UART Communication
    input wire rx,
    output wire tx,

    // Intruction Control
    input wire [31:0] pc,
    output reg        cpu_reset,cpu_run,
    output reg [31:0] instr,

    // Memory Control
    input  wire write_enable,
    input  wire read_enable,

    // Memory Data
    input  wire [31:0] writeData,
    output reg  [31:0] readData,
    input  wire [31:0] address,
    input  wire [1:0]  MemWrite,
    input  wire [2:0]  SizeLoad
);

// FSM States
localparam  IDLE = 4'b0000,
            CPU_READY = 4'b0001,
            RESET_CPU = 4'b0010,
            SEND_PC = 4'b0011,
            WAIT_INST = 4'b0100,
            RUN_CPU = 4'b0101,
            SEND_ADDRESS = 4'b00110,
            SEND_SIZELOAD = 4'b00111,
            WAIT_RECV_DATA = 4'b1000,
            RECV_DATA = 4'b1001,
            SEND_MEMWRITE = 4'b1010,
            SEND_DATA = 4'b1011;

reg [3:0] state;
reg [3:0] next_state;  

always @(posedge clk) begin
    if(reset) begin
        state <= IDLE;
    end
    else begin
        state <= next_state;
    end
end

// UART Instances
wire [31:0] recv_data;
wire        recv_ready;
reg        send_start;
reg [31:0] send_data;
wire        send_ready;
reg        one_byte_rx, one_byte_tx;

uart_32bit_rx uart_rx (
    .clk      ( clk ),
    .reset    ( reset ),
    .rx       ( rx ),
    .one_byte ( one_byte_rx ),
    .data_out ( recv_data ),
    .data_end ( recv_ready )
);

uart_32bit_tx uart_tx(
    .clk        ( clk ),
    .reset      ( reset ),
    .send_start ( send_start ),
    .data_in    ( send_data ),
    .one_byte   ( one_byte_tx ),
    .tx         ( tx ),
    .data_end   ( send_ready )
);

reg [31:0] instr_prev, readData_prev;
always @(posedge clk) begin
    if(reset) begin
        instr_prev <= 'b0;
        readData_prev <= 'b0;
    end
    else begin
        instr_prev <= instr;
        readData_prev <= readData;
    end
end

always @(*) begin
    next_state = state;
    cpu_reset = 0;
    cpu_run = 0;
    instr = instr_prev;

    readData = readData_prev;
    send_start = 0;
    send_data = 0;

    one_byte_rx = 0;
    one_byte_tx = 0;
    case(state)
        IDLE: begin
            readData = 0;
            instr = 0;
            next_state = RESET_CPU;
        end
        CPU_READY: begin
            readData = 0;
            instr = 0;

            send_start = 1;
            send_data = 1'b1;
            one_byte_rx = 1;
            one_byte_tx = 1;
            if( send_ready && recv_ready ) begin
                if( recv_data == 2'b01) next_state = RESET_CPU;
                else if( recv_data == 2'b10 ) next_state = SEND_PC;
                else next_state = WAIT_INST;
            end
            else next_state = CPU_READY;
        end
        RESET_CPU: begin
            cpu_reset = 1;
            next_state = CPU_READY;
        end
        SEND_PC: begin
            send_start = 1;
            send_data = pc;
            if( send_ready ) next_state = CPU_READY;
            else next_state = SEND_PC;
        end
        WAIT_INST: begin
            if( recv_ready ) next_state = RUN_CPU;
            else next_state = WAIT_INST;
        end
        RUN_CPU: begin
            instr = recv_data;
            cpu_run = 1;
            if( write_enable || read_enable ) next_state = SEND_ADDRESS;
            else next_state = CPU_READY;
        end
        SEND_ADDRESS: begin
            send_start = 1;
            send_data = address;
            if( send_ready && write_enable ) next_state = SEND_MEMWRITE;
            else if ( send_ready && read_enable ) next_state = SEND_SIZELOAD;
            else next_state = SEND_ADDRESS;
        end
        SEND_SIZELOAD: begin
            send_start = 1;
            send_data = SizeLoad;
            one_byte_tx = 1;
            if( send_ready ) next_state = WAIT_RECV_DATA;
            else next_state = SEND_SIZELOAD;
        end
        WAIT_RECV_DATA: begin
            if( recv_ready ) next_state = RECV_DATA;
            else next_state = WAIT_RECV_DATA;
        end
        RECV_DATA: begin
            readData = recv_data;
            next_state = CPU_READY;
        end
        SEND_MEMWRITE: begin
            send_start = 1;
            send_data = MemWrite;
            one_byte_tx = 1;
            if( send_ready ) next_state = SEND_ADDRESS;
            else next_state = SEND_MEMWRITE;
        end
        SEND_DATA: begin
            send_start = 1;
            send_data = writeData;
            if( send_ready ) next_state = CPU_READY;
            else next_state = SEND_DATA;
        end
    endcase
end

endmodule
