//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.01.2022 11:57:33
// Design Name: 
// Module Name: uart_sm_rx
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


module uart_sm_rx(
    input wire clk, reset,
    input wire rx,
    output reg [7:0] byte_out,
    output reg byte_end
    );
    
    //cycles count ---------------------------------------------------------------------------------------------------------------------
   
    reg [4:0] count;
    reg [4:0] pre_count;
    
    always @(posedge clk) begin
        if(reset) begin
            count <= 0;
        end
        else count <= pre_count;
    end
    
    //bit count -----------------------------------------------------------------------------------------------------------------------
    
    reg [3:0] bit_count;
    reg [3:0] pre_bit_count;
    
    always @(posedge clk) begin
        if(reset) bit_count <= 0;
        else bit_count <= pre_bit_count;
    end
    
    //byte out -----------------------------------------------------------------------------------------------------------------------
    
    reg [7:0] pre_byte_out;
    
    always @(posedge clk) begin
        if(reset) byte_out <= 0;
        else byte_out <= pre_byte_out;
    end
    
    //state machine ---------------------------------------------------------------------------------------------------------------------
    
    reg [1:0] state;
    reg [1:0] next_state;
    
    localparam IDLE = 0;
    localparam START = 1;
    localparam WAIT_FRONT = 2;
    localparam WAIT_BACK = 3;
    
    always @(posedge clk) begin
        if(reset) state <= IDLE;
        else state <= next_state;
    end
    
    always @(*) begin
        next_state = state;
        pre_count = count;
        pre_bit_count = bit_count;
        pre_byte_out = byte_out;
        byte_end = 0;
        case(state)
            IDLE: begin
                next_state = START;
            end
            
            START: begin
                if(rx==0) begin
                    next_state = WAIT_FRONT;
                    pre_bit_count = 0;
                end
            end
            
            WAIT_FRONT: begin
                pre_count = count + 1;
                if(count==15) begin
                    pre_bit_count = bit_count + 1; 
                    pre_count = 0;
                    next_state = WAIT_BACK;
                    case(bit_count)
                        1: pre_byte_out[0] = rx;
                        2: pre_byte_out[1] = rx;
                        3: pre_byte_out[2] = rx;
                        4: pre_byte_out[3] = rx;
                        5: pre_byte_out[4] = rx;
                        6: pre_byte_out[5] = rx;
                        7: pre_byte_out[6] = rx;
                        8: pre_byte_out[7] = rx;
                        9: begin
                            next_state = IDLE;
                            byte_end = 1;
                        end
                    endcase
                end
            end
            
            WAIT_BACK: begin
                pre_count = count + 1;
                if(count==15) begin
                    next_state = WAIT_FRONT;
                    pre_count = 0;
                end
            end
        endcase
    end
endmodule
