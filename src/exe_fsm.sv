`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.03.2022 13:01:05
// Design Name: 
// Module Name: exe_fsm
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


module exe_fsm(
    input logic clk,reset,start,run,
    output logic instr_query,cpu_run
    );
    
    localparam IDLE = 0;
    localparam INSTQ = 1;
    localparam RUNING = 2;
    
    logic [1:0] state;
    logic [1:0] next_state;
    
    always_ff@(posedge clk) begin
        if(reset) state <= IDLE;
        else state <= next_state;
    end
    
    always_comb begin
        instr_query = 0;
        cpu_run = 0;
        next_state = state;
        case(state)
            IDLE: begin
                if(start) begin
                    next_state = INSTQ;
                end
            end
            INSTQ: begin
                instr_query = 1;
                if(run) begin
                    next_state = RUNING;
                end
            end
            RUNING: begin
                cpu_run = 1;
                if(start) begin
                    next_state = IDLE;
                end
                else next_state = INSTQ;
            end
        endcase
    end
   
endmodule
