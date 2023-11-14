module top (
    input wire clk,reset,//reset2,
    input wire rx,
    output wire tx
);

// Intruction Control
wire [31:0] pc;
wire cpu_reset, cpu_run;
wire [31:0] instr;

// Memory Control
wire write_enable, read_enable;

// Memory Data
wire [31:0] writeData, readData, address;
wire [1:0] MemWrite;
wire [2:0] SizeLoad;

//wire locked;
//wire clk_div;
//clk_wiz_0 inst
//  ( 
//  .clk_out1(clk_div),               
//  .reset(~reset), 
//  .locked(locked),
//  .clk_in1(clk)
//  );

wire [3:0]state_com ;
wire recv_ready_com;
wire [31:0]recv_data_com;

com_controller com_controller(
    .clk(clk),
    .reset(~reset),
    .rx(rx),
    .tx(tx),
    .pc(pc),
    .cpu_reset(cpu_reset),
    .cpu_run(cpu_run),
    .instr(instr),
    .write_enable(write_enable),
    .read_enable(read_enable),
    .writeData(writeData),
    .readData(readData),
    .address(address),
    .MemWrite(MemWrite),
    .SizeLoad(SizeLoad),
    .state_com(state_com),
    .recv_ready_com(recv_ready_com),
    .recv_data_com(recv_data_com)
);

wire [31:0] ALU_result;

cpu_usm_v1 cpu_usm_v1(
    .clk(cpu_run),
    .reset(cpu_reset),
    .instr(instr), 
    .data_in(readData),
    .PC(pc), 
    .data_out(writeData),
    .ALU_result(ALU_result),
    .MemWrite(MemWrite),
    .SizeLoad(SizeLoad),                     //Needed to the load 
    .ResultSrc(read_enable)                  //is like a MemLoad -> 0: No lee, 1: Senal de lectura 
);

assign write_enable = |MemWrite;
assign address = ALU_result;

//ila_0 ila_com(
//    .clk(clk),
//    .probe0(rx),   // 1bit 
//    .probe1(recv_ready_com), // 1bit 
//    .probe2(state_com),   // 4 bit 
//    .probe3(recv_data_com[7:0]),  // 32 bit
//    .probe4(tx)
//); 


endmodule
