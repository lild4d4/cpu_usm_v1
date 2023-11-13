//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.01.2022 13:09:58
// Design Name: 
// Module Name: clock_divider
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module clock_divider #(parameter N = 100)(
    input wire clk, reset,
    output reg divided_clk
    );
    
    reg [31:0] counter_value;
    
    always @(posedge clk)
        if(reset || counter_value == N)
            counter_value <= 0;
        else
            counter_value <= counter_value +1;
           
    always @(posedge clk)
    begin
        if(reset) divided_clk <= 0;
        else if(counter_value == N)
            divided_clk <= ~divided_clk;
        else
            divided_clk <= divided_clk;
    end
endmodule
