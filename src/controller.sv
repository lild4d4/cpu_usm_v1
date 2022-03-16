`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.02.2022 13:07:29
// Design Name: 
// Module Name: controller
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


module controller(
    //Inputs
    input logic [6:0] opcode, funct7,
    input logic [2:0] funct3,
    input logic [3:0] Flags,
    //Outputs
    output logic RegWrite, ALUSrc, ResultSrc,
    output logic [3:0] ALUControl,
    output logic [1:0] MemWrite, PCtoRd, PCSrc,
    output logic [2:0] SizeLoad, ImmSrc
    );
    
    logic ALUOp, ALUAdd, StoreOp, LoadOp, Branch;
    logic [1:0] passcond;
    logic [1:0] PCSrc_inter;
    
    maindecoder maindec(opcode,funct3,RegWrite, ALUSrc, ALUOp, ALUAdd, StoreOp, LoadOp, ResultSrc, Branch,PCtoRd,PCSrc_inter,ImmSrc);
    
    aludecoder aludec(Branch,ALUAdd,ALUOp,funct7,funct3,ALUControl);
    
    condlogic condlog(Branch,funct3,Flags,passcond);
    
    sizecontroller sizecon(LoadOp, StoreOp,funct3,MemWrite,SizeLoad);
    
    assign PCSrc = passcond & PCSrc_inter;
    
endmodule
