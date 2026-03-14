# High-Performance Multi-Channel Mem-to-Mem DMA Controller IP

![Platform](https://img.shields.io/badge/Platform-Xilinx_Vivado-blue)
![Language](https://img.shields.io/badge/Language-Verilog-green)
![Protocol](https://img.shields.io/badge/Protocol-AXI4--Full_/_AXI4--Lite-red)
![Architecture](https://img.shields.io/badge/Architecture-Pipelined_FIFO-orange)
![Verification](https://img.shields.io/badge/Verification-Advanced_Self--Checking-success)

## Project Overview

This project presents a highly optimized, fully synthesizable **Multi-Channel DMA (Direct Memory Access) Controller** IP core, designed specifically for **Memory-to-Memory (Mem-to-Mem)** bulk data transfers in modern System-on-Chip (SoC) architectures.

By autonomously managing high-speed data duplication between memory spaces (e.g., SRAM, DDR) using the **AXI4 Master Full Burst** protocol, this IP drastically offloads the host CPU, eliminating computational bottlenecks and maximizing system bus throughput.

---

## Key Features

* **4-Channel Concurrent Architecture:** Four independent DMA channels, each equipped with dedicated Source, Destination, and Transfer Length registers.
* **Hardware Round-Robin Arbitration:** A dynamic, fair-share hardware scheduler (`dma_arbiter`) guarantees that no active channel suffers from bus starvation.
* **Industrial AXI4 Protocol Integration:**
    * **AXI4-Lite Slave:** A low-latency configuration interface featuring a robust Latching Handshake to ensure compatibility with all standard CPUs.
    * **AXI4 Master Full:** Dual data engines (Read/Write) utilizing **Burst INCR** mode to continuously push/pull massive data payloads.
* **Data Pipelining via Synchronous FIFO:** An internal 32-bit parameterized FIFO decouples Read and Write domains, enabling true parallel processing (simultaneous fetching and flushing).
* **Hardware Interlock & W1C Protection:** * Automatically locks channel configurations (`BUSY` state) to reject illegal CPU overwrites during active transfers.
    * Industry-standard **Write-1-to-Clear (W1C)** mechanism for the `DONE` flag to ensure safe interrupt/status handling.

---

## System Architecture

The design is heavily modularized, separating control logic from the high-speed data path:

1. **Control Plane (`dma_axi_lite_slave`, `dma_reg_bank`):** Decodes CPU instructions, safely stores 32-bit addresses/lengths, and manages FSM states.
2. **Scheduling Plane (`dma_arbiter`):** Constantly monitors channel requests (`ch_req`) and grants bus ownership based on real-time engine availability.
3. **Execution Plane (`dma_read_engine`, `dma_write_engine`, `dma_fifo`):** * The **Read Engine** masters the AXI bus to burst-read memory into the FIFO. It intelligently handles `RLAST` and backpressure.
    * The **Write Engine** tracks FIFO capacity and bursts data to the destination, asserting `DONE` only upon receiving a valid AXI Write Response (`BVALID`).

---
The design is heavily modularized, separating control logic from the high-speed data path.

```text
+--------------------------------------------------------------------------------+
|                              System-on-Chip (SoC)                              |
|                                                                                |
|  +----------------+                                        +----------------+  |
|  |                |                                        |                |  |
|  |    Host CPU    |                                        |   System RAM   |  |
|  |  (Testbench)   |                                        |  (Memory Model)|  |
|  |                |                                        |                |  |
|  +-------+--------+                                        +--------+-------+  |
|          | (AXI4-Lite)                                              | (AXI4)   |
|          v                                                          |          |
|  +---------------------------------------------------------------+  |          |
|  |             MULTI-CHANNEL MEM-TO-MEM DMA CONTROLLER           |  |          |
|  |                                                               |  |          |
|  |  +----------------+  [Registers]  +------------------------+  |  |          |
|  |  |                +-------------->|                        |  |  |          |
|  |  | AXI-Lite Slave |               |  Register Bank (4-Ch)  |  |  |          |
|  |  |   Interface    |<--------------+ (SRC, DST, LEN, CTRL)  |  |  |          |
|  |  |                |   [Status]    |                        |  |  |          |
|  |  +----------------+               +-----------+------------+  |  |          |
|  |                                               | ch_req[3:0]   |  |          |
|  |                                               v               |  |          |
|  |                                   +------------------------+  |  |          |
|  |                                   |                        |  |  |          |
|  |                                   |  Round-Robin Arbiter   |  |  |          |
|  |                                   |                        |  |  |          |
|  |                                   +------+----------+------+  |  |          |
|  |                                 Grant ID |          | Grant ID|  |          |
|  |                                          v          v         |  |          |
|  |  +----------------+  [Push]       +---------+    +---------+  |  |          |
|  |  |                +-------------->|         |    |         |  |  |          |
|  |  |  Read Engine   |               | Sync    |    |  Write  |  |  |          |
|  +--+ (AXI4 Master)  |               | FIFO    |--->| Engine  +--+  |          |
|     |                |               | (64x32) |    | (AXI4)  |     |          |
|     +--------+-------+               +---------+    +----+----+     |          |
|              |                                           |          |          |
|==============|===========================================|==========|==========|
|              | AXI4 Burst Read                           | AXI4 Burst Write    |
|              +-------------------------------------------+                     |
+--------------------------------------------------------------------------------+

```
## Advanced Verification Methodology

The IP core was subjected to extreme stress testing using an advanced **Self-Checking Testbench** environment (`tb_dma_top.v`). The verification suite includes a custom CPU BFM and a zero-latency AXI4 RAM model.

### Test Scenarios Passed:
1. **Single Channel Sanity:** Basic burst fetching and flushing.
2. **Interlock Protection Test:** Intentionally deploying the CPU BFM to inject corrupted addresses (`0xDEADBEEF`) into an active channel. The hardware successfully blocked the attack.
3. **Extreme Multi-Channel Stress:** Simultaneously firing all 4 channels with drastically different payload sizes (64B to 512B), forcing the Arbiter and FIFO into extreme context-switching.

### Verification Log (Zero Data Corruption):
```text
==============================================
  START DMA CONTROLLER VERIFICATION
==============================================

TEST 1 : Single Channel Transfer
...
  => Verifying: SRC(0x00001000) -> DST(0x00001500) | 128 bytes
Transfer verified successfully (32 words)

TEST 2 : Interlock Protection
...
  => Verifying: SRC(0x00002000) -> DST(0x00002500) | 256 bytes
Transfer verified successfully (64 words)

TEST 3 : Multi-Channel Stress
...
  => Verifying: SRC(0x00001000) -> DST(0x00001800) | 256 bytes
Transfer verified successfully (64 words)
  => Verifying: SRC(0x00002000) -> DST(0x00002800) | 128 bytes
Transfer verified successfully (32 words)
  => Verifying: SRC(0x00003000) -> DST(0x00003800) | 64 bytes
Transfer verified successfully (16 words)
  => Verifying: SRC(0x00004000) -> DST(0x00004800) | 512 bytes
Transfer verified successfully (128 words)

==============================================
PASSED : No data corruption detected.
==============================================
