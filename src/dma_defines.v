`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/13/2026 08:10:37 PM
// Design Name: 
// Module Name: dma_defines
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
/////////////////////////////////////////////////////////////////////////////////
`ifndef DMA_DEFINES_V
`define DMA_DEFINES_V

//config
`define NUM_CHANNELS   4
`define ADDR_WIDTH     32 //bits
`define DATA_WIDTH     32

// memory size of each channel 16 bytes = 0x10
`define CH_ADDR_OFFSET 8'h10

// Offset of each reg in 1 channel
`define REG_SRC_ADDR   8'h00  // source
`define REG_DST_ADDR   8'h04  // dest
`define REG_LENGTH     8'h08 
`define REG_CTRL_STAT  8'h0C  // control

//  Bit in CTRL_STAT
`define BIT_START      0  
`define BIT_DONE       1  
`define BIT_BUSY       2 
`define BIT_ERR        3  

`endif