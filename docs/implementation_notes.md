# Implementation notes and source corrections

This package implements the intent of **Lab 1 — DFX: Runtime Module Swap on ZCU102** while keeping source-derived behavior separate from corrections needed for an executable flow.

## Preserved lab architecture
- ZCU102 / XCZU9EG-2FFVB1156E.
- Static region: Zynq UltraScale+ MPSoC, 100 MHz FCLK0, AXI GPIO, free-running 32-bit heartbeat counter.
- Reconfigurable partition: `u_pattern` with interface `clk`, `rst_n`, `led[7:0]`.
- RM-A: one-hot LED chaser.
- RM-B: 8-bit LFSR pattern.
- DFX Decoupler safe value on `led[7:0]`: `8'h00`.
- Runtime handshake: reset RM -> decouple -> load partial -> release reset -> recouple.

## Corrections / executable clarifications
1. **Heartbeat simulation initialization**: the lab counter has no reset/initial value but the testbench later expects a numeric count. In 4-state RTL simulation, an uninitialized counter can remain `X`; this package initializes `count` to zero.
2. **LFSR LED initialization**: the lab resets `lfsr` but not `led`, so output can remain `X` until the first divider event. This package resets `led` to `8'hAC`.
3. **Behavioral RM switching**: the lab testbench instantiates RM-A only. This package instantiates both RMs and uses a simulation-only selector to model which RM is resident. This is not a replacement for physical DFX; it verifies reset/decouple sequencing and static continuity before hardware.
4. **`pr_verify`**: AMD UG909 specifies comparison of routed configurations. `verify_and_write_bitstreams.tcl` compares Config A and Config B explicitly before generating bitstreams.
5. **Static preservation for Config B**: AMD's DFX sequence removes the first RM with `update_design -cell ... -black_box`, locks static routing, saves a static checkpoint, then inserts the second RM. `dfx_config_b_from_a.tcl` follows that sequence.
6. **XilFPGA API**: the supplied lab uses `XFpga_PartialBtcnfg()`. The maintained Xilinx embeddedsw example uses `XFpga_BitStream_Load(..., XFPGA_PARTIAL_EN)` for non-Versal partial loading; `vitis/main.c` follows that public API.
7. **Partial bitstream naming**: directional names in the lab are easy to misread. This package names images by the RM they contain: `partial_chaser.bit` and `partial_lfsr.bit`.
8. **Divider timing note**: with a 100 MHz clock, the shown `div[21]` condition is reached after about 2,097,152 cycles (~20.97 ms), not ~4.2 ms. The RTL expression is preserved; only the interpretation is corrected here.

## What cannot be truthfully pre-generated here
- A valid `sys.bd`, implemented DCP, full `.bit`, or partial `.bit` requires Vivado 2023.2 with the ZCU102 board files/IP and the DFX feature available.
- Hardware proof requires a physical ZCU102, JTAG/UART connections, and a running A53 application.

The repository therefore treats hardware-generated files and pass/fail evidence as outputs to be produced on the target toolchain, not as pre-filled claims.
