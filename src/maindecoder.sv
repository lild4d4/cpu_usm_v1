`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.02.2022 21:25:44
// Design Name: 
// Module Name: maindecoder
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


module maindecoder(
    //Inputs
    input logic [6:0] opcode,
    input logic [2:0] funct3,
    //Outputs
    output logic RegWrite, ALUSrc, ALUOp, ALUAdd, StoreOp, LoadOp, ResultSrc, Branch,
    output logic [1:0] PCtoRd, PCSrc,
    output logic [2:0] ImmSrc
    );
    
    logic [14:0] controls;
    
    always_comb begin
        case(opcode)
            7'b0110011: controls = 15'b1xxx00000000000;             //Arithmetic and Shift
            7'b0010011: begin                                       //Imm Arithmetic
                if(funct3 == 3'b001 || funct3 == 3'b101) begin
                    controls = 15'b110110000000000;
                end
                else begin
                    controls = 15'b100011000000000;
                end
            end
            7'b0100011: controls = 15'b000110110xxx000;             //Store
            7'b0000011: controls = 15'b100010101100000;             //Load
            7'b1100011: controls = 15'b001000000xxx011;             //Branch
            7'b1100111: controls = 15'b100010100001100;             //JALR
            7'b1101111: controls = 15'b1100x0000x01010;             //JAL
            7'b0110111: controls = 15'b1011x0000x10000;             //LUI
            7'b0010111: controls = 15'b1011x0000x11000;             //AUIPC
            default: controls = 15'b000000000000000;
        endcase
    end
    
    assign {RegWrite,ImmSrc,ALUSrc,ALUOp,ALUAdd,StoreOp,LoadOp,ResultSrc,PCtoRd,PCSrc,Branch} = controls;
    
endmodule
