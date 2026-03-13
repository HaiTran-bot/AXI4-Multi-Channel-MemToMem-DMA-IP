`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/13/2026 11:27:46 PM
// Design Name: 
// Module Name: dma_fifo
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
module dma_fifo #(
    parameter DATA_WIDTH = 32,
    parameter DEPTH      = 64
)(
    input  wire                  clk,
    input  wire                  rst_n,
 
    input  wire                  wr_en,
    input  wire [DATA_WIDTH-1:0] din,
    output wire                  full,
 
    input  wire                  rd_en,
    output wire [DATA_WIDTH-1:0] dout,
    output wire                  empty
);
 
    localparam PTR_W = $clog2(DEPTH); 
 
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    reg [PTR_W-1:0] wr_ptr;
    reg [PTR_W-1:0] rd_ptr;
    reg [PTR_W:0]   count; // 1 bit thêm để phân biệt full/empty
 
    assign full  = (count == DEPTH);
    assign empty = (count == 0);
 
    always @(posedge clk) begin
        if (wr_en && !full) mem[wr_ptr] <= din;
    end
 
    assign dout = mem[rd_ptr];
 
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            count  <= 0;
        end else begin
            case ({wr_en && !full, rd_en && !empty})
                2'b10: begin wr_ptr <= wr_ptr + 1; count <= count + 1; end
                2'b01: begin rd_ptr <= rd_ptr + 1; count <= count - 1; end
                2'b11: begin wr_ptr <= wr_ptr + 1; rd_ptr <= rd_ptr + 1; end
                default: begin wr_ptr <= wr_ptr; count <= count; end     
            endcase
        end
    end
 
endmodule