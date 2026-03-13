`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/13/2026 11:26:15 PM
// Design Name: 
// Module Name: dma_write_engine
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
module dma_write_engine #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter BURST_LEN  = 16
)(
    input  wire                   clk,
    input  wire                   rst_n,
 
    input  wire                   start,
    input  wire [ADDR_WIDTH-1:0]  dst_addr,
    input  wire [31:0]            transfer_len,
    output reg                    write_done,
 
    input  wire                   fifo_empty,
    output wire                   fifo_rd_en,
    input  wire [DATA_WIDTH-1:0]  fifo_dout,
 
    output reg  [ADDR_WIDTH-1:0]  m_axi_awaddr,
    output reg                    m_axi_awvalid,
    input  wire                   m_axi_awready,
    output wire [7:0]             m_axi_awlen,
    output wire [2:0]             m_axi_awsize,
    output wire [1:0]             m_axi_awburst,
 
    output wire [DATA_WIDTH-1:0]  m_axi_wdata,
    output wire                   m_axi_wvalid,
    input  wire                   m_axi_wready,
    output wire                   m_axi_wlast,
 
    input  wire [1:0]             m_axi_bresp,
    input  wire                   m_axi_bvalid,
    output wire                   m_axi_bready
);
 
    localparam ST_IDLE    = 4'b0001;
    localparam ST_WR_ADDR = 4'b0010;
    localparam ST_WR_DATA = 4'b0100;
    localparam ST_WR_RESP = 4'b1000;
 
    reg [3:0]  current_state, next_state;
    reg [31:0] bytes_written_cnt;
    reg [7:0]  burst_cnt;
    
    reg is_active;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)           is_active <= 1'b0;
        else if (start)       is_active <= 1'b1;
        else if (write_done)  is_active <= 1'b0;
    end
 
    wire [31:0] bytes_next = bytes_written_cnt + (DATA_WIDTH/8);
 
    assign m_axi_awlen   = BURST_LEN - 1;
    assign m_axi_awsize  = 3'b010;
    assign m_axi_awburst = 2'b01;
    
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) current_state <= ST_IDLE;
        else        current_state <= next_state;
    end
 
    always @(*) begin
        next_state = current_state;
        case (current_state)
            ST_IDLE:    if (is_active && !fifo_empty) next_state = ST_WR_ADDR;
            ST_WR_ADDR: if (m_axi_awvalid && m_axi_awready) next_state = ST_WR_DATA;
            ST_WR_DATA: if (m_axi_wvalid && m_axi_wready && m_axi_wlast) next_state = ST_WR_RESP;
            ST_WR_RESP: begin
                if (m_axi_bvalid && m_axi_bready) begin
                    if (bytes_written_cnt >= transfer_len) next_state = ST_IDLE;
                    else next_state = ST_WR_ADDR;
                end
            end
        endcase
    end
 
    assign m_axi_wvalid = (current_state == ST_WR_DATA) && !fifo_empty;
    assign m_axi_wdata  = fifo_dout;
    assign fifo_rd_en   = m_axi_wvalid && m_axi_wready;
    assign m_axi_wlast  = (burst_cnt == (BURST_LEN - 1));
    assign m_axi_bready = (current_state == ST_WR_RESP);
 
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            m_axi_awvalid     <= 0;
            m_axi_awaddr      <= 0;
            bytes_written_cnt <= 0;
            burst_cnt         <= 0;
            write_done        <= 0;
        end else begin
            case (current_state)
                ST_IDLE: begin
                    write_done <= 0;
                    burst_cnt  <= 0;
                    if (start) begin 
                        m_axi_awaddr      <= dst_addr;
                        bytes_written_cnt <= 0;
                    end
                end
                ST_WR_ADDR: begin
                    m_axi_awvalid <= 1'b1;
                    if (m_axi_awready) begin
                        m_axi_awvalid <= 1'b0;
                        m_axi_awaddr  <= m_axi_awaddr + (BURST_LEN * (DATA_WIDTH/8));
                    end
                end
                ST_WR_DATA: begin
                    if (m_axi_wvalid && m_axi_wready) begin
                        burst_cnt         <= burst_cnt + 1;
                        bytes_written_cnt <= bytes_written_cnt + (DATA_WIDTH/8);
                    end
                end
                ST_WR_RESP: begin
                    burst_cnt <= 0;
                    if (m_axi_bvalid && m_axi_bready && (bytes_written_cnt >= transfer_len))
                        write_done <= 1'b1;
                end
            endcase
        end
    end
 
endmodule
