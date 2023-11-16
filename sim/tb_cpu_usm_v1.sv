module tb_cpu_usm_v1();
  
    logic clk,reset,reset2;
    logic rx, tx;
	
	riscv DUT(clk, reset, reset2, rx, tx);
            
	// generate a clock signal that inverts its value every five time units
	always  #5 clk=~clk;
	
	//here we assign values to the inputs
	
	task send_byte;
	   input [7:0] data_8;
	   begin
	       #8681 rx = 0;
	       #8681 rx = data_8[0];
	       #8681 rx = data_8[1];
	       #8681 rx = data_8[2];
	       #8681 rx = data_8[3];
	       #8681 rx = data_8[4];
	       #8681 rx = data_8[5];
	       #8681 rx = data_8[6];
	       #8681 rx = data_8[7];
	       #8681 rx = 1;
	   end
	endtask
	
	task send_instruccion;
	   input [31:0] instruccion;
	   begin
	       send_byte(8'd0);
	       send_byte(instruccion[7:0]);
	       send_byte(instruccion[15:8]);
	       send_byte(instruccion[23:16]);
	       send_byte(instruccion[31:24]);
	   end
	endtask
	
	task send_data;
	   input [31:0] instruccion;
	   begin
	       send_byte(instruccion[7:0]);
	       send_byte(instruccion[15:8]);
	       send_byte(instruccion[23:16]);
	       send_byte(instruccion[31:24]);
	   end
	endtask
	
	initial begin
		clk = 1'b0;
		reset = 1'b0;
		reset2 = 1'b0;
		rx = 1'b1;
		#10000 
		reset = 1'b1;
		#100000
		reset2 = 1'b1;
		#100000
		send_instruccion(32'h00500113);
		#100000
		send_byte(8'd2);
		#800000
		send_instruccion(32'h00C00193);
		#100000
		send_instruccion(32'h00900813);
		#100000
		send_instruccion(32'h410183B3);
		#100000
		send_instruccion(32'h0023E233);
		#100000
		send_instruccion(32'h0041F2B3);
		#100000
		send_instruccion(32'h004282B3);
		#100000
		send_instruccion(32'h40728433);
		#100000
		send_instruccion(32'h4C728363);
		#100000
		send_instruccion(32'h40418433);
		#100000
		send_instruccion(32'h0041D463);
		#100000
		send_instruccion(32'h40238433);
		#100000
		send_instruccion(32'h00128393);
		#100000
		send_instruccion(32'h402383b3);
		#100000
		send_instruccion(32'h0471aa23);
		#1000000
		send_instruccion(32'h06002103);
		#1000000
		send_data(32'd7);
		#1000000
		send_instruccion(32'h00800a6f);
	end

endmodule