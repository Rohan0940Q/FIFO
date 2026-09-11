# FIFO
# Dual-Clock FIFO (8-bit × 64) — Clock Domain Crossing Analysis

A Verilog implementation of an asynchronous (dual-clock) FIFO buffer, built to explore
the design challenges of transferring data safely between two independent clock domains.

## Overview

- **Depth / Width:** 64 entries × 8 bits
- **Interface:** Independent write clock (`clk_w`) and read clock (`clk_r`), separate
  write/read enables, circular-buffer addressing via wrapping pointers, combinational
  full/empty flag generation.
- **Status:** Functional for single-domain / non-concurrent access. Contains a known,
  documented clock-domain-crossing (CDC) bug under concurrent read/write — see below.

## Known Issue: Shared Counter Across Clock Domains

The design uses a single occupancy counter (`fifo_counter`) to derive `full`/`empty`
flags. This counter is incremented in an `always @(posedge clk_w)` block and
decremented in a separate `always @(posedge clk_r)` block — i.e. **one register driven
by two independent, unrelated clocks.**

This is not synthesis-safe and causes non-deterministic behavior under concurrent
read/write activity, for two reasons:

1. **Multiple drivers:** two clocked always blocks cannot legally co-own a single
   register; most tools will flag this at elaboration/synthesis.
2. **Metastability risk even if the multi-driver issue were resolved:** a multi-bit
   binary value crossing between unrelated clock domains can have several bits change
   at once. If sampled mid-transition by the receiving clock, the observed value can be
   an arbitrary garbage number, not just "off by one."

## The Correct Fix (documented, not yet implemented in this version)

The standard, industry-accepted solution for asynchronous FIFOs:

1. Replace the single shared counter with **two independent pointers** — a write
   pointer owned entirely by `clk_w`, and a read pointer owned entirely by `clk_r`.
   This removes the multi-driver problem outright, since each register now has exactly
   one clock.
2. Encode each pointer in **Gray code**, where only one bit changes between any two
   consecutive values. This bounds the worst-case CDC sampling error to "one count
   old or new," instead of an arbitrary garbage value.
3. Pass each pointer into the *other* clock domain through a **2-flop synchronizer**,
   allowing any transient metastability to resolve before the value is used downstream.
4. Derive `full`/`empty` locally in each domain by comparing the local pointer against
   the synchronized version of the other domain's pointer (with the standard MSB-invert
   trick to disambiguate full vs. empty when pointers are equal).

## Repo Contents

| File | Description |
|---|---|
| `fifo.v` | Dual-clock FIFO RTL (contains the CDC issue described above) |
| `fifo_tb.v` | Self-checking testbench with independent, unrelated read/write clocks and a scoreboard, used to exercise and observe the CDC behavior under concurrent access |

## Why Keep the Bug in the Repo?

This repo is intentionally kept in its current state (bug included, fix documented but
not applied) as a worked example of a real clock-domain-crossing failure mode and its
resolution — the kind of issue commonly discussed in RTL/ASIC/FPGA design interviews.
A corrected, Gray-code-synchronized version may be added as a follow-up.

## Tech Stack

RTL Design (Verilog), Clock Domain Crossing (CDC) fundamentals, Digital Design Debugging
