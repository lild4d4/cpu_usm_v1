module extend(
    input wire [31:0] Instr,
    input wire [2:0] ImmSrc,
    output reg [31:0] ExtImm
    );
    always @(*) begin
        case(ImmSrc)
                            //I-TYPE: 12-bit signed immediate
            3'b000: ExtImm = {{21{Instr[31]}}, Instr[30:20]};
            
                            //S-TYPE
            3'b001: ExtImm = {{21{Instr[31]}}, Instr[30:25],Instr[11:7]};
            
                            //B-TYPE
            3'b010: ExtImm = {{20{Instr[31]}}, Instr[7],Instr[30:25],Instr[11:8],1'b0};
            //3'b010: ExtImm = 32'd3;
            
                            //U-TYPE
            3'b011: ExtImm = {Instr[31],Instr[30:20],Instr[19:12],{12{~1}}};
            
                            //J-TYPE
            3'b100: ExtImm = {{12{Instr[31]}},Instr[19:12],Instr[20],Instr[30:21],1'b0};
            //3'b100: ExtImm = 32'd3;
                            //I-TYPE_MOD -> for SLLI/SRLI/SRAI
            3'b101: ExtImm = {{27{~1}}, Instr[24:20]};
                            
            default: ExtImm = 32'bx;
        endcase
    end
endmodule