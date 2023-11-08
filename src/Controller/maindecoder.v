module maindecoder(
    //Inputs
    input wire [6:0] opcode,
    input wire [2:0] funct3,
    //Outputs
    output wire RegWrite, ALUSrc, ALUOp, ALUAdd, StoreOp, LoadOp, ResultSrc, Branch,
    output wire [1:0] PCtoRd, PCSrc,
    output wire [2:0] ImmSrc
    );
    
    reg [14:0] controls;
    
    always @(*) begin
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