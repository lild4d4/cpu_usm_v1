module cpu_usm_v1(
    //Inputs
    input wire clk,reset,
    input wire [31:0] instr, data_in,
    //Outputs
    output wire [31:0] PC, data_out, write_direction,extend_data,
    output wire [1:0] MemWrite,
    output wire [2:0] SizeLoad
    );
    
    wire [6:0] opcode;
    wire [6:0] funct7;
    wire [2:0] funct3,ImmSrc;
    wire [3:0] Flags,ALUControl;
    wire RegWrite,ALUSrc,ResultSrc;
    wire [1:0] PCtoRd,PCSrc;
    
    wire [4:0] rs1,rs2,rd;
    wire [31:0] rd1,rd2_1,rd2_2,data_reg,ALU_result,pctarget_result,next_pc,next_pc_2,ResultSrc_data;
    
    assign opcode = instr[6:0];
    assign funct7 = instr[31:25];
    assign funct3 = instr[14:12];
    assign rs2 = instr[24:20];
    assign rs1 = instr[19:15];
    assign rd = instr[11:7];
    
    assign data_out = rd2_1;
    
    flopr #(32) flop(clk,reset,next_pc_2,PC);
    
    //Controller
    controller con(opcode,funct7,funct3,Flags,RegWrite,ALUSrc,ResultSrc,ALUControl,MemWrite,PCtoRd,PCSrc,SizeLoad,ImmSrc);
        
    //regfile
    regfile rf(clk,RegWrite,rs1,rs2,rd,data_reg,rd1,rd2_1);
    
    //extend
    extend extendcontroller(instr,ImmSrc,extend_data);
    //assign imm32 = {29'b0,ImmSrc};
    
    //ALU
    mux2 #(32) alumux(rd2_1,extend_data,ALUSrc,rd2_2);
    alu #(32) aluu(rd1,rd2_2,ALUControl,ALU_result,Flags);
    
    assign write_direction = ALU_result;
    
    

    //Result Src
    mux2 #(32) resultsrcmux(ALU_result,data_in,ResultSrc,ResultSrc_data);
    
    //PCTarget
    adder pctarget(extend_data,PC,pctarget_result);
    
    //preflop mux
    mux3 #(32) preflopmux(next_pc,pctarget_result,ResultSrc_data,PCSrc,next_pc_2);
    
    
    
    
    //PLUS 4
    adder plus4(PC,32'd4,next_pc);
    
    //PCtoRd
    mux4 #(32) pctordmux(ResultSrc_data,next_pc,extend_data,pctarget_result,PCtoRd,data_reg);
    
endmodule