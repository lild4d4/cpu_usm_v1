`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.02.2022 21:17:55
// Design Name: 
// Module Name: sizecontroller
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


module sizecontroller(
    //Inputs
    input logic LoadOp, StoreOp,
    input logic [2:0] funct3,
    //Outputs
    output logic [1:0] MemWrite,
    output logic [2:0] SizeLoad
    );
    
    always_comb begin
        MemWrite = 2'b00;
        SizeLoad = 3'b000;
        if(StoreOp) begin
            case(funct3)
                 3'b010: MemWrite = 2'b01;
                 3'b000: MemWrite = 2'b11;
                 3'b001: MemWrite = 2'b10;
                 default: MemWrite = 2'b00; 
            endcase
        end
        else begin
            if(LoadOp) begin
                case(funct3)
                    3'b000: SizeLoad = 3'b010;
                    3'b001: SizeLoad = 3'b001;
                    3'b010: SizeLoad = 3'b000;
                    3'b100: SizeLoad = 3'b011;
                    3'b101: SizeLoad = 3'b100;
                    default: SizeLoad = 3'b000;
                endcase
            end
            else begin
                MemWrite = 2'b00;
                SizeLoad = 3'b000;
            end
        end
    end
    
endmodule
