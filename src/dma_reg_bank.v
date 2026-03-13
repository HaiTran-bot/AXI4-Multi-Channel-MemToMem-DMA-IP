`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/13/2026 09:31:46 PM
// Design Name: 
// Module Name: dma_reg_bank
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
`include "dma_defines.v"

module dma_reg_bank (
    input  wire                               clk,
    input  wire                               rst_n,
 
    // Write interface từ AXI-Lite Slave
    input  wire                               reg_wr_en,
    input  wire [7:0]                         reg_wr_addr,
    input  wire [`DATA_WIDTH-1:0]             reg_wr_data,
 
    // Read interface từ AXI-Lite Slave 
    input  wire                               reg_rd_en,
    input  wire [7:0]                         reg_rd_addr,
    output reg  [`DATA_WIDTH-1:0]             reg_rd_data,
 
    // Output cho Arbiter & Engines 
    output reg  [`NUM_CHANNELS-1:0]           ch_req,
    output reg  [(`NUM_CHANNELS*`ADDR_WIDTH)-1:0] ch_src_flat,
    output reg  [(`NUM_CHANNELS*`ADDR_WIDTH)-1:0] ch_dst_flat,
    output reg  [(`NUM_CHANNELS*32)-1:0]          ch_len_flat,
 
    input  wire [`NUM_CHANNELS-1:0]           ch_engine_done,
    input  wire [`NUM_CHANNELS-1:0]           ch_engine_busy
);
 
    reg [`ADDR_WIDTH-1:0] ch_src_int  [0:`NUM_CHANNELS-1];
    reg [`ADDR_WIDTH-1:0] ch_dst_int  [0:`NUM_CHANNELS-1];
    reg [31:0]            ch_len_int  [0:`NUM_CHANNELS-1];
    reg [31:0]            ch_ctrl_int [0:`NUM_CHANNELS-1];
 
    integer i, j;
    wire [1:0] ch_idx     = reg_wr_addr[5:4];
    wire [3:0] reg_offset = reg_wr_addr[3:0];
 
    // ---------- Write ----------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < `NUM_CHANNELS; i = i + 1) begin
                ch_src_int[i]  <= 0;
                ch_dst_int[i]  <= 0;
                ch_len_int[i]  <= 0;
                ch_ctrl_int[i] <= 0;
            end
        end else begin
            if (reg_wr_en) begin
                if (!ch_engine_busy[ch_idx]) begin
                    case (reg_offset)
                        `REG_SRC_ADDR: ch_src_int[ch_idx] <= reg_wr_data;
                        `REG_DST_ADDR: ch_dst_int[ch_idx] <= reg_wr_data;
                        `REG_LENGTH:   ch_len_int[ch_idx] <= reg_wr_data;
                    endcase
                end
                if (reg_offset == `REG_CTRL_STAT) begin
                    ch_ctrl_int[ch_idx][`BIT_START] <= reg_wr_data[`BIT_START];
                    if (reg_wr_data[`BIT_DONE])
                        ch_ctrl_int[ch_idx][`BIT_DONE] <= 1'b0;
                end
            end
            for (i = 0; i < `NUM_CHANNELS; i = i + 1) begin
                ch_ctrl_int[i][`BIT_BUSY] <= ch_engine_busy[i];
                if (ch_engine_done[i]) begin
                    ch_ctrl_int[i][`BIT_START] <= 1'b0;
                    ch_ctrl_int[i][`BIT_DONE]  <= 1'b1;
                end
            end
        end
    end
 
    // ---------- Read ----------
    wire [1:0] rd_ch_idx     = reg_rd_addr[5:4];
    wire [3:0] rd_reg_offset = reg_rd_addr[3:0];
 
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            reg_rd_data <= 0;
        end else if (reg_rd_en) begin
            case (rd_reg_offset)
                `REG_SRC_ADDR:  reg_rd_data <= ch_src_int[rd_ch_idx];
                `REG_DST_ADDR:  reg_rd_data <= ch_dst_int[rd_ch_idx];
                `REG_LENGTH:    reg_rd_data <= ch_len_int[rd_ch_idx];
                `REG_CTRL_STAT: reg_rd_data <= ch_ctrl_int[rd_ch_idx];
                default:        reg_rd_data <= 32'hDEAD_BEEF;
            endcase
        end
    end
 
    // ---------- Flat output ----------
    always @(*) begin
        for (j = 0; j < `NUM_CHANNELS; j = j + 1) begin
            ch_src_flat[j * `ADDR_WIDTH +: `ADDR_WIDTH] = ch_src_int[j];
            ch_dst_flat[j * `ADDR_WIDTH +: `ADDR_WIDTH] = ch_dst_int[j];
            ch_len_flat[j * 32 +: 32]                   = ch_len_int[j];
            ch_req[j] = ch_ctrl_int[j][`BIT_START] & ~ch_ctrl_int[j][`BIT_DONE];
        end
    end
 
endmodule
