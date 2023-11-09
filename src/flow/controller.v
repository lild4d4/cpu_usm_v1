module controller(
    //Inputs
    input wire [6:0] opcode, funct7,
    input wire [2:0] funct3,
    input wire [3:0] Flags,
    //Outputs
    output wire RegWrite, ALUSrc, ResultSrc,
    output wire [3:0] ALUControl,
    output wire [1:0] MemWrite, PCtoRd, PCSrc,
    output wire [2:0] SizeLoad, ImmSrc
    );
    
    wire ALUOp, ALUAdd, StoreOp, LoadOp, Branch;
    wire [1:0] passcond;
    wire [1:0] PCSrc_inter;
    
    maindecoder maindec(opcode,funct3,RegWrite, ALUSrc, ALUOp, ALUAdd, StoreOp, LoadOp, ResultSrc, Branch,PCtoRd,PCSrc_inter,ImmSrc);
    
    aludecoder aludec(Branch,ALUAdd,ALUOp,funct7,funct3,ALUControl);
    
    condlogic condlog(Branch,funct3,Flags,passcond);
    
    sizecontroller sizecon(LoadOp, StoreOp,funct3,MemWrite,SizeLoad);
    
    assign PCSrc = passcond & PCSrc_inter;
    
endmodule