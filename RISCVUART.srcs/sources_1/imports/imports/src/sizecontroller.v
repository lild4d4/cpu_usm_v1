module sizecontroller(
    //Inputs
    input wire LoadOp, StoreOp,
    input wire [2:0] funct3,
    //Outputs
    output reg [1:0] MemWrite,
    output reg [2:0] SizeLoad
    );
    
    always @(*) begin
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
