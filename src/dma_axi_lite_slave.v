`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/13/2026 11:28:34 PM
// Design Name: 
// Module Name: dma_axi_lite_slave
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
module dma_axi_lite_slave (
    input  wire          clk, rst_n,

    // --- AXI-Lite Write Channel ---
    input  wire [7:0]    s_axi_awaddr,
    input  wire          s_axi_awvalid,
    output reg           s_axi_awready,
    input  wire [31:0]   s_axi_wdata,
    input  wire          s_axi_wvalid,
    output reg           s_axi_wready,
    output reg  [1:0]    s_axi_bresp,
    output reg           s_axi_bvalid,
    input  wire          s_axi_bready,
 
    // --- AXI-Lite Read Channel ---
    input  wire [7:0]    s_axi_araddr,
    input  wire          s_axi_arvalid,
    output reg           s_axi_arready,
    output reg  [31:0]   s_axi_rdata,
    output reg  [1:0]    s_axi_rresp,
    output reg           s_axi_rvalid,
    input  wire          s_axi_rready,
 
    // --- Interface với reg_bank ---
    output reg           reg_wr_en,
    output reg  [7:0]    reg_wr_addr,
    output reg  [31:0]   reg_wr_data,
    output reg           reg_rd_en,
    output reg  [7:0]    reg_rd_addr,
    input  wire [31:0]   reg_rd_data
);
 
    reg aw_latched, w_latched;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s_axi_awready <= 0; s_axi_wready  <= 0;
            s_axi_bvalid  <= 0; s_axi_bresp   <= 2'b00;
            reg_wr_en     <= 0; reg_wr_addr   <= 0; reg_wr_data   <= 0;
            aw_latched    <= 0; w_latched     <= 0;
        end else begin
            if (s_axi_awvalid && !s_axi_awready && !aw_latched) begin
                s_axi_awready <= 1'b1;
                aw_latched    <= 1'b1;
                reg_wr_addr   <= s_axi_awaddr;
            end else begin
                s_axi_awready <= 1'b0;
            end
 
            if (s_axi_wvalid && !s_axi_wready && !w_latched) begin
                s_axi_wready <= 1'b1;
                w_latched    <= 1'b1;
                reg_wr_data  <= s_axi_wdata;
            end else begin
                s_axi_wready <= 1'b0;
            end
 
            if (aw_latched && w_latched && !reg_wr_en && !s_axi_bvalid) begin
                reg_wr_en <= 1'b1;
            end else begin
                reg_wr_en <= 1'b0;
            end
 
            if (reg_wr_en && !s_axi_bvalid) begin
                s_axi_bvalid <= 1'b1;
                s_axi_bresp  <= 2'b00;
                aw_latched   <= 1'b0; 
                w_latched    <= 1'b0;
            end else if (s_axi_bvalid && s_axi_bready) begin
                s_axi_bvalid <= 1'b0;
            end
        end
    end
 
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s_axi_arready <= 0; s_axi_rvalid <= 0;
            s_axi_rdata   <= 0; s_axi_rresp  <= 2'b00;
            reg_rd_en     <= 0; reg_rd_addr  <= 0;
        end else begin
            if (s_axi_arvalid && !s_axi_arready && !reg_rd_en && !s_axi_rvalid) begin
                s_axi_arready <= 1'b1;
                reg_rd_addr   <= s_axi_araddr;
                reg_rd_en     <= 1'b1;
            end else begin
                s_axi_arready <= 1'b0;
                reg_rd_en     <= 1'b0;
            end
 

            if (reg_rd_en) begin
                s_axi_rvalid <= 1'b1;
                s_axi_rdata  <= reg_rd_data;
                s_axi_rresp  <= 2'b00;
            end else if (s_axi_rvalid && s_axi_rready) begin
                s_axi_rvalid <= 1'b0;
            end
        end
    end
endmodule