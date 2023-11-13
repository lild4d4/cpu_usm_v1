module alu #(parameter C_WIDTH = 8) //ADD=0000, SUB=0001, AND=0010, OR=0011, XOR= 0100, SLT = 0101, SLTU = 0111, SLL = 1000, SRL = 1001, SRA = 1011
(
	input wire [C_WIDTH-1:0] A,
	input wire [C_WIDTH-1:0] B,
	input wire [3:0] opcode,

	output reg [C_WIDTH-1:0] Result,
	output reg [3:0] Status
);
	reg N, Z, C, V; // ALU Flags

	always @(*) begin
	   C=0;
	   V=0;
		case(opcode)
			4'b0000: begin //ADD
			    /* El operador {} se usa para concatenar bits que pueden venir de distintos buses.
			       Notar que se esta guardando el resultado de la suma en un elemento que tiene un bit mas de ancho que los operandos,
			       lo cual forzara a la herramienta a que extienda en un bit el ancho de los operandos, como si fuera un sumador de 9 bits.
			       Es importante notar que el bit extra se usa para el carry flag y no es parte del resultado de la operacion. 
			       Hay varias formas de describir esta operacion. Con practica iran aprendiendo trucos.
			    */ 
				{C, Result} = A + B; 
				V = (Result[C_WIDTH-1] & ~A[C_WIDTH-1] & ~B[C_WIDTH-1]) | (~Result[C_WIDTH-1] & A[C_WIDTH-1] & B[C_WIDTH-1]);
			    // Hay overflow si el resultado es positivo y los operandos son negativos, o si el resultado es positivo y los operandos son negativos
			end

			4'b0001: begin //SUB
				{C, Result} = A - B;
				V = (Result[C_WIDTH-1] & ~A[C_WIDTH-1] & B[C_WIDTH-1]) | (~Result[C_WIDTH-1] & A[C_WIDTH-1] & ~B[C_WIDTH-1]);
			   // Hay overflow si A es negativo, B es positivo, y Result es positivo; o bien si A es positivo, B es negativo, y Result es negativo.
			end

			4'b0011: begin //ORR
				Result = A | B;
				C = 1'b0;
				V = 1'b0;
			end

			4'b0010: begin //AND
			    Result = A & B;
				C = 1'b0;
				V = 1'b0;
		    	end
				
		    4'b0100: begin //XOR
			    Result = A^B;
			end
			
			4'b0101: begin //SLT
			    if($signed(A)<$signed(B)) Result = 1;
			    else Result = 0;
			end
			
			4'b0111: begin //SLTU
			    if(A < B) Result = 1;
			    else Result = 0;
			end
			
			4'b1000: begin //SLL
			    Result = A<<B;
			end
			
			4'b1001: begin //SRL
			    Result = A>>B;
			end
			
			4'b1011: begin //SRA
			    Result = A>>>B;
			end
			
			default: Result = 'bx;
			
		endcase

		N = Result[C_WIDTH-1]; // el flag N cablea directo al MSB de Result
		Z = (Result == 'd0);    // revisa si el resultado es 0

		// se usa la concatenacion para agrupar bits independiente en un bus.
		Status = {N, Z, C, V};
	end
endmodule
