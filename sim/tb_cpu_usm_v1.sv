module tb_cpu_usm_v1();
  
    logic clk,reset;
    logic [31:0] instr, data_in;
    logic [31:0] PC, data_out, ALU_result;
    logic [1:0] MemWrite;
    logic [2:0] SizeLoad;             //Needed to the load 
    logic ResultSrc;
	
	cpu_usm_v1 DUT(clk, reset, instr, data_in, PC, data_out, ALU_result, MemWrite, SizeLoad, ResultSrc);
            
	// generate a clock signal that inverts its value every five time units
	//always  #0.5 clk=~clk;
	
	//here we assign values to the inputs
	initial begin
		clk = 1'b0;
		reset = 1'b1;
		instr = 32'h00000000;
		#10 reset = 1'b0;
		#100 clk = 1;
		#100 clk = 0;
		instr = 32'h00200093;
		#100 clk = 1;
		#100 clk = 0;
		instr = 32'h0010A023;
		#100 clk = 1;
		#100 clk = 0;
	end

endmodule