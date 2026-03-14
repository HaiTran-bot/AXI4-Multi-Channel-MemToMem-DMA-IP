`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/13/2026 11:24:38 PM
// Design Name: 
// Module Name: dma_read_engine
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
module dma_read_engine #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter BURST_LEN  = 16
)(
    input  wire                   clk,
    input  wire                   rst_n,
    input  wire                   start,
    input  wire [ADDR_WIDTH-1:0]  src_addr,
    input  wire [31:0]            transfer_len,
    output reg                    read_done,
    input  wire                   fifo_full,
    output wire                   fifo_wr_en,
    output wire [DATA_WIDTH-1:0]  fifo_din,
    output reg  [ADDR_WIDTH-1:0]  m_axi_araddr,
    output reg                    m_axi_arvalid,
    input  wire                   m_axi_arready,
    output wire [7:0]             m_axi_arlen,
    output wire [2:0]             m_axi_arsize,
    output wire [1:0]             m_axi_arburst,
    input  wire [DATA_WIDTH-1:0]  m_axi_rdata,
    input  wire                   m_axi_rvalid,
    output wire                   m_axi_rready,
    input  wire                   m_axi_rlast,
    input  wire [1:0]             m_axi_rresp
);

    localparam ST_IDLE    = 4'b0001;
    localparam ST_RD_ADDR = 4'b0010;
    localparam ST_RD_DATA = 4'b0100;
    localparam ST_RD_DONE = 4'b1000;

    reg [3:0]  current_state, next_state;
    reg [31:0] bytes_read_cnt;
 
    wire [31:0] bytes_next = bytes_read_cnt + 4;

    assign m_axi_arlen   = BURST_LEN - 1;
    assign m_axi_arsize  = 3'b010; // 4 bytes/beat
    assign m_axi_arburst = 2'b01;  // INCR
 
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) current_state <= ST_IDLE;
        else        current_state <= next_state;
    end
 
    always @(*) begin
        next_state = current_state;
        case (current_state)
            ST_IDLE:    if (start) next_state = ST_RD_ADDR;
            ST_RD_ADDR: if (m_axi_arvalid && m_axi_arready) next_state = ST_RD_DATA;
            ST_RD_DATA: begin
                if (m_axi_rvalid && m_axi_rready && m_axi_rlast) begin
                    if (bytes_next >= transfer_len) next_state = ST_RD_DONE;
                    else                            next_state = ST_RD_ADDR;
                end
            end
            ST_RD_DONE: next_state = ST_IDLE;
            default:    next_state = ST_IDLE;
        endcase
    end
 
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            m_axi_araddr   <= 0;
            m_axi_arvalid  <= 0;
            bytes_read_cnt <= 0;
            read_done      <= 0;
        end else begin
            case (current_state)
                ST_IDLE: begin
                    read_done      <= 0;
                    bytes_read_cnt <= 0;
                    if (start) m_axi_araddr <= src_addr;
                end
                ST_RD_ADDR: begin
                    // [FIXED BUG]: Logic Handshake an toàn tuyệt đối
                    if (!m_axi_arvalid) begin
                        m_axi_arvalid <= 1'b1;
                    end else if (m_axi_arready) begin
                        m_axi_arvalid <= 1'b0;
                        m_axi_araddr  <= m_axi_araddr + (BURST_LEN * (DATA_WIDTH/8));
                    end
                end
                ST_RD_DATA: begin
                    if (m_axi_rvalid && m_axi_rready)
                        bytes_read_cnt <= bytes_read_cnt + (DATA_WIDTH/8);
                end
                ST_RD_DONE: read_done <= 1'b1;
            endcase
        end
    end
 
    assign m_axi_rready = !fifo_full;
    assign fifo_wr_en   = m_axi_rvalid && m_axi_rready;
    assign fifo_din     = m_axi_rdata;
 
endmodule