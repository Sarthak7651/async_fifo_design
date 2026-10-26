# Asynchronous FIFO Design

A parameterizable **asynchronous (dual-clock) FIFO** written in RTL, used to safely pass data between two unrelated clock domains. The design uses Gray-coded pointers and two-flip-flop synchronizers to avoid metastability and data-corruption issues at the clock domain crossing (CDC).


---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [How It Works](#how-it-works)
- [Interface](#interface)
- [Repository Structure](#repository-structure)
- [Getting Started](#getting-started)
- [Verification](#verification)
- [Schematic](#schematic)
- [Future Work](#future-work)
- [Author](#author)

---

## Overview

When a producer and a consumer run on different, unrelated clocks, data cannot be passed directly without risking metastability and lost or duplicated data. An asynchronous FIFO solves this by buffering data in dual-port memory, with the write side and read side each controlled by their own clock domain.

This project implements that FIFO at RTL level, together with its synthesized schematic.

## Features

- Independent write clock (`wclk`) and read clock (`rclk`)
- Parameterizable data width and depth (`DATA_WIDTH`, `ADDR_WIDTH`)
- Gray-coded read/write pointers for safe CDC
- Two-flip-flop synchronizers for pointer crossing
- Registered `full` (write domain) and `empty` (read domain) flags
- Separate active-low asynchronous resets per domain 
- Synthesizable RTL

## Architecture

```
          Write Clock Domain (wclk)                     Read Clock Domain (rclk)
   ┌──────────────────────────────────┐          ┌──────────────────────────────────┐
   │                                  │          │                                  │
   │  Write Pointer &  ──► wptr (Gray)│──────────┼──► 2-FF Sync ──► wptr_sync       │
   │  Full Logic       ◄── rptr_sync  │◄─────────┼─── 2-FF Sync ◄── rptr (Gray)     │
   │                                  │          │          Read Pointer &          │
   │       waddr                      │          │          Empty Logic   raddr     │
   └───────┬──────────────────────────┘          └─────────────────────┬────────────┘
           │                  ┌─────────────────┐                      │
           └─── wdata, wen ──►│  Dual-Port RAM  │◄───────── ren ───────┘
                              │  (FIFO memory)  │────────► rdata
                              └─────────────────┘
```

### Modules

| Module | Description |
| --- | --- |
| `[fifo_top]` | Top-level wrapper connecting all submodules |
| `[fifo_mem]` | Dual-port memory written on `wclk`, read on `rclk` |
| `[wptr_full]` | Write pointer, Gray conversion, and `full` flag generation |
| `[rptr_empty]` | Read pointer, Gray conversion, and `empty` flag generation |
| `[sync_r2w]` | Synchronizes the read pointer into the write clock domain |
| `[sync_w2r]` | Synchronizes the write pointer into the read clock domain |

## How It Works

1. **Pointers are one bit wider than the address.** An `ADDR_WIDTH + 1` bit pointer lets the design tell a full FIFO apart from an empty one when the address bits are equal.
2. **Gray coding.** Pointers are converted to Gray code before crossing domains, so only one bit changes per increment. A synchronizer that samples mid-transition therefore sees either the old or the new value, never an invalid one.
3. **Two-flip-flop synchronization.** Each Gray pointer passes through two back-to-back flip-flops in the destination clock domain to reduce the probability of metastability.
4. **Empty flag (read domain).** The FIFO is empty when the read pointer equals the synchronized write pointer.
5. **Full flag (write domain).** The FIFO is full when the next write pointer equals the synchronized read pointer with the two MSBs inverted and the remaining bits equal.

Because the synchronized pointers lag the real ones, the flags are conservative: `full` may assert slightly early and `empty` may deassert slightly late, but the FIFO never overflows or underflows.

## Interface

### Parameters

| Parameter | Default | Description |
| --- | --- | --- |
| `DATA_WIDTH` | `[8]` | Width of each data word |
| `ADDR_WIDTH` | `[4]` | Address width (depth = 2^ADDR_WIDTH) |

### Ports

| Port | Dir | Domain | Description |
| --- | --- | --- | --- |
| `wclk` | in | Write | Write clock |
| `wrst_n` | in | Write | Active-low write reset |
| `winc` | in | Write | Write enable |
| `wdata` | in | Write | Write data |
| `wfull` | out | Write | FIFO full flag |
| `rclk` | in | Read | Read clock |
| `rrst_n` | in | Read | Active-low read reset |
| `rinc` | in | Read | Read enable |
| `rdata` | out | Read | Read data |
| `rempty` | out | Read | FIFO empty flag |

> Update the names above to match your top module.

## Repository Structure

```
async_fifo_design/
├── images/              # Waveforms, diagrams, and screenshots
├── rtl_design_code/     # Synthesizable RTL source files
├── schematic_design/    # Synthesized / elaborated schematic outputs
└── README.md
```

## Getting Started

### Prerequisites

- A Verilog/SystemVerilog simulator, for example ModelSim/QuestaSim, Vivado Simulator, Icarus Verilog, or Verilator 
- Optional: Vivado / Quartus / Yosys for synthesis and schematic viewing

### Clone

```bash
git clone https://github.com/Sarthak7651/async_fifo_design.git
cd async_fifo_design
```

### Simulate (example with Icarus Verilog)

```bash
iverilog -g2012 -o fifo_sim rtl_design_code/*.v
vvp fifo_sim
gtkwave dump.vcd
```

> Adjust file extensions and commands to match your sources and testbench.

## Verification

Suggested scenarios to cover (and document results for in `images/`):

- Reset behavior: `empty` asserted and `full` deasserted after reset
- Write until full, then confirm further writes are blocked
- Read until empty, then confirm further reads are blocked
- Simultaneous read and write
- Different clock ratios (fast write / slow read, slow write / fast read)
- Data integrity: data read out matches data written, in order

Waveform results: see the [`images/`](images/) folder.

## Schematic

The synthesized schematic is available in [`schematic_design/`](schematic_design/).

## Future Work

- Almost-full / almost-empty flags
- Self-checking testbench with a scoreboard
- Formal verification of the CDC logic
- FPGA implementation and timing/CDC report

## Author

**Sarthak** — [@Sarthak7651](https://github.com/Sarthak7651)
