module top (
    input wire clk,reset,
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

/* wire clk_div;
clock_divider #(10) clk_di(clk, ~reset, clk_div); */

clk_wiz_0 inst
  ( 
  .clk_out1(clk_div),               
  .reset(~reset), 
  .locked('b0),
  .clk_in1(clk)
  );


com_controller com_controller(
    .clk(clk_div),
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
    .SizeLoad(SizeLoad)
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

/* ila_0 ila_com(
    .clk(clk),
    .probe0(rx),
    .probe1(recv_ready2),
    .probe2(state2),
    .probe3(recv_ready_rx),
    .probe4(recv_data_rx)
); */


endmodule
