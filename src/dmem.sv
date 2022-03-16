`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.02.2022 18:29:55
// Design Name: 
// Module Name: dmem
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


module dmem(
    input logic clk,
    input logic [1:0] MemWrite,
    input logic [2:0] SizeLoad,
    input logic [31:0] a,wd,
    output logic [31:0] rd
    );
    
    logic [1:0][1:0][7:0] RAM[63:0];
    
    always_comb begin
        case(SizeLoad)
            3'b010: rd = {{24{RAM[a[31:2]][a[1]][a[0]][7]}},RAM[a[31:2]][a[1]][a[0]]};  //LB
            3'b001: rd = {{16{RAM[a[31:2]][a[1]][a[1]][7]}},RAM[a[31:2]][a[1]]};        //LH
            3'b000: rd = RAM[a[31:2]];                                                  //LW
            3'b011: rd = {{24{~1}},RAM[a[31:2]][a[1]][a[0]]};                           //LBU
            3'b101: rd = {{16{~1}},RAM[a[31:2]][a[1]]};                                 //LHU
            default: rd = 32'd0;
        endcase
    end
    
    always_ff @(posedge clk)
      case(MemWrite)
        2'b01: RAM[a[31:2]] <= wd; // sw 
        2'b10: RAM[a[31:2]][a[1]] <= wd[15:0]; // sh
        2'b11: RAM[a[31:2]][a[1]][a[0]] <= wd[7:0]; // sb
        // do nothing
    endcase
    
endmodule
