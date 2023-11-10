module condlogic(
    //inputs
    input wire Branch,
    input wire [2:0] funct3,
    input wire [3:0] Flags,
    //ouputs
    output reg [1:0] passcond
    );
    
    wire neg, zero, carry, overflow, ge;
    
    //Flags = {N, Z, C, V};
    assign {neg, zero, carry, overflow} = Flags;
    assign ge = (neg == overflow); //Greater Equal
    
    always @(*) begin
        passcond = 2'b00;
        if(Branch==0) begin
            passcond = 2'b11;
        end
        else begin
            case(funct3) 
                3'b000: if(zero) passcond = 2'b11; // equal
                3'b001: if(~zero) passcond = 2'b11; // not equal
                3'b100: if(~ge) passcond = 2'b11; //less than
                3'b101: if(ge) passcond = 2'b11;  //greater equal
                3'b111: if(carry) passcond = 2'b11; //greater equal unsigned
                3'b110: if(~carry) passcond = 2'b11; //less than unsigned
                default: passcond = 2'b11;
            endcase
        end
    end
    
endmodule