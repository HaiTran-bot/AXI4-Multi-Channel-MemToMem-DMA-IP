`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/14/2026 12:21:22 AM
// Design Name: 
// Module Name: axi_lite_master_bfm
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
module axi_lite_master_bfm (
    input  wire          clk,
    

    output reg  [7:0]    awaddr,
    output reg           awvalid,
    input  wire          awready,
    
    output reg  [31:0]   wdata,
    output reg           wvalid,
    input  wire          wready,
    
    input  wire [1:0]    bresp,
    input  wire          bvalid,
    output reg           bready
);


    initial begin
        awaddr  = 0; awvalid = 0;
        wdata   = 0; wvalid  = 0;
        bready  = 0;
    end

    task write_reg;
        input [7:0]  addr;
        input [31:0] data;
        begin
            @(posedge clk);
            
            awaddr  = addr;  awvalid = 1'b1;
            wdata   = data;  wvalid  = 1'b1;
            bready  = 1'b1;  


            while (!awready || !wready) begin
                @(posedge clk);
            end
            
 
            @(posedge clk);
            awvalid = 1'b0;
            wvalid  = 1'b0;

 
            while (!bvalid) begin
                @(posedge clk);
            end
            
            @(posedge clk);
            bready = 1'b0;
            
            $display("[%0t] [CPU_BFM] Successfully write Data: 0x%h to Address: 0x%h", $time, data, addr);
        end
    endtask

endmodule
