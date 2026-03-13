`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/13/2026 11:29:26 PM
// Design Name: 
// Module Name: dma_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include "dma_defines.v"

module dma_top (
    input  wire clk,
    input  wire rst_n,
 
    // AXI-Lite Slave (CPU)
    input  wire [7:0]   s_axi_awaddr,
    input  wire         s_axi_awvalid,
    output wire         s_axi_awready,
    input  wire [31:0]  s_axi_wdata,
    input  wire         s_axi_wvalid,
    output wire         s_axi_wready,
    output wire [1:0]   s_axi_bresp,
    output wire         s_axi_bvalid,
    input  wire         s_axi_bready,
 
    // AXI-Lite Read 
    input  wire [7:0]   s_axi_araddr,
    input  wire         s_axi_arvalid,
    output wire         s_axi_arready,
    output wire [31:0]  s_axi_rdata,
    output wire [1:0]   s_axi_rresp,
    output wire         s_axi_rvalid,
    input  wire         s_axi_rready,
 
    // AXI4 Full Master Read
    output wire [31:0]  m_axi_araddr,
    output wire         m_axi_arvalid,
    input  wire         m_axi_arready,
    output wire [7:0]   m_axi_arlen,
    output wire [2:0]   m_axi_arsize,
    output wire [1:0]   m_axi_arburst,
    input  wire [31:0]  m_axi_rdata,
    input  wire         m_axi_rvalid,
    output wire         m_axi_rready,
    input  wire         m_axi_rlast,
    input  wire [1:0]   m_axi_rresp,
 
    // AXI4 Full Master Write
    output wire [31:0]  m_axi_awaddr,
    output wire         m_axi_awvalid,
    input  wire         m_axi_awready,
    output wire [7:0]   m_axi_awlen,
    output wire [2:0]   m_axi_awsize,
    output wire [1:0]   m_axi_awburst,
    output wire [31:0]  m_axi_wdata,
    output wire         m_axi_wvalid,
    input  wire         m_axi_wready,
    output wire         m_axi_wlast,
    input  wire [1:0]   m_axi_bresp,
    input  wire         m_axi_bvalid,
    output wire         m_axi_bready
);
 
    wire        w_reg_wr_en;
    wire [7:0]  w_reg_wr_addr;
    wire [31:0] w_reg_wr_data;
    wire        w_reg_rd_en;
    wire [7:0]  w_reg_rd_addr;
    wire [31:0] w_reg_rd_data;
 
    wire [`NUM_CHANNELS-1:0] w_ch_req, w_ch_engine_busy, w_ch_engine_done;
    wire [(`NUM_CHANNELS*`ADDR_WIDTH)-1:0] w_ch_src_flat, w_ch_dst_flat;
    wire [(`NUM_CHANNELS*32)-1:0]          w_ch_len_flat;
 
    wire        w_grant_valid;
    wire [1:0]  w_grant_ch_id;
 
    wire        w_fifo_full, w_fifo_empty, w_fifo_wr_en, w_fifo_rd_en;
    wire [31:0] w_fifo_din, w_fifo_dout;
    wire        w_read_done, w_write_done;
 
    wire w_write_start = w_read_done;
 
    wire w_engine_idle = (!w_grant_valid) && (w_ch_engine_busy == {`NUM_CHANNELS{1'b0}});
 
    wire [31:0] active_src_addr = w_ch_src_flat[w_grant_ch_id * 32 +: 32];
    wire [31:0] active_dst_addr = w_ch_dst_flat[w_grant_ch_id * 32 +: 32];
    wire [31:0] active_len      = w_ch_len_flat[w_grant_ch_id * 32 +: 32];
 
    dma_axi_lite_slave u_slave (
        .clk(clk), .rst_n(rst_n),
        .s_axi_awaddr(s_axi_awaddr), .s_axi_awvalid(s_axi_awvalid), .s_axi_awready(s_axi_awready),
        .s_axi_wdata(s_axi_wdata),   .s_axi_wvalid(s_axi_wvalid),   .s_axi_wready(s_axi_wready),
        .s_axi_bresp(s_axi_bresp),   .s_axi_bvalid(s_axi_bvalid),   .s_axi_bready(s_axi_bready),
        .s_axi_araddr(s_axi_araddr), .s_axi_arvalid(s_axi_arvalid), .s_axi_arready(s_axi_arready),
        .s_axi_rdata(s_axi_rdata),   .s_axi_rresp(s_axi_rresp),     .s_axi_rvalid(s_axi_rvalid),
        .s_axi_rready(s_axi_rready),
        .reg_wr_en(w_reg_wr_en), .reg_wr_addr(w_reg_wr_addr), .reg_wr_data(w_reg_wr_data),
        .reg_rd_en(w_reg_rd_en), .reg_rd_addr(w_reg_rd_addr), .reg_rd_data(w_reg_rd_data)
    );
 
    dma_reg_bank u_reg_bank (
        .clk(clk), .rst_n(rst_n),
        .reg_wr_en(w_reg_wr_en), .reg_wr_addr(w_reg_wr_addr), .reg_wr_data(w_reg_wr_data),
        .reg_rd_en(w_reg_rd_en), .reg_rd_addr(w_reg_rd_addr), .reg_rd_data(w_reg_rd_data),
        .ch_req(w_ch_req),
        .ch_src_flat(w_ch_src_flat),
        .ch_dst_flat(w_ch_dst_flat),
        .ch_len_flat(w_ch_len_flat),
        .ch_engine_done(w_ch_engine_done), .ch_engine_busy(w_ch_engine_busy)
    );
 
    dma_arbiter u_arbiter (
        .clk(clk), .rst_n(rst_n),
        .ch_req(w_ch_req),
        .engine_idle(w_engine_idle),  // Fix: dùng wire đã tính sẵn
        .grant_valid(w_grant_valid), .grant_ch_id(w_grant_ch_id),
        .ch_engine_busy(w_ch_engine_busy)
    );
 
    dma_read_engine u_read_engine (
        .clk(clk), .rst_n(rst_n),
        .start(w_grant_valid),
        .src_addr(active_src_addr), .transfer_len(active_len), .read_done(w_read_done),
        .fifo_full(w_fifo_full), .fifo_wr_en(w_fifo_wr_en), .fifo_din(w_fifo_din),
        .m_axi_araddr(m_axi_araddr), .m_axi_arvalid(m_axi_arvalid), .m_axi_arready(m_axi_arready),
        .m_axi_arlen(m_axi_arlen),   .m_axi_arsize(m_axi_arsize),   .m_axi_arburst(m_axi_arburst),
        .m_axi_rdata(m_axi_rdata),   .m_axi_rvalid(m_axi_rvalid),   .m_axi_rready(m_axi_rready),
        .m_axi_rlast(m_axi_rlast),   .m_axi_rresp(m_axi_rresp)
    );
 
    dma_fifo u_fifo (
        .clk(clk), .rst_n(rst_n),
        .wr_en(w_fifo_wr_en), .din(w_fifo_din),   .full(w_fifo_full),
        .rd_en(w_fifo_rd_en), .dout(w_fifo_dout), .empty(w_fifo_empty)
    );
 
    dma_write_engine u_write_engine (
        .clk(clk), .rst_n(rst_n),
        .start(w_grant_valid), 
        .dst_addr(active_dst_addr), .transfer_len(active_len), .write_done(w_write_done),
        .fifo_empty(w_fifo_empty), .fifo_rd_en(w_fifo_rd_en), .fifo_dout(w_fifo_dout),
        .m_axi_awaddr(m_axi_awaddr), .m_axi_awvalid(m_axi_awvalid), .m_axi_awready(m_axi_awready),
        .m_axi_awlen(m_axi_awlen),   .m_axi_awsize(m_axi_awsize),   .m_axi_awburst(m_axi_awburst),
        .m_axi_wdata(m_axi_wdata),   .m_axi_wvalid(m_axi_wvalid),   .m_axi_wready(m_axi_wready),
        .m_axi_wlast(m_axi_wlast),
        .m_axi_bresp(m_axi_bresp), .m_axi_bvalid(m_axi_bvalid), .m_axi_bready(m_axi_bready)
    );
 
    // ch_engine_done set khi write_done, dùng grant_ch_id đang giữ
    assign w_ch_engine_done = w_write_done ? ({{(`NUM_CHANNELS-1){1'b0}}, 1'b1} << w_grant_ch_id)
                                           : {`NUM_CHANNELS{1'b0}};
 
endmodule
