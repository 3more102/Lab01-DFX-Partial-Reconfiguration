# Remaining Lab Work — Vivado / ZCU102 Only

Everything in this file requires the AMD Vivado/Vitis 2023.2 toolchain and/or a physical ZCU102. These items are intentionally not marked PASS until real evidence is produced.

## Completed without the board

- Repository/source integrity checked.
- SystemVerilog compiles under Icarus Verilog.
- Behavioral DFX sequence passes in GitHub Actions.
- Modeled A -> B -> A switching passes.
- Modeled decoupling forces the observed boundary to `0x00`.
- Modeled static heartbeat remains monotonic through both swap windows.
- Tcl scripts for RM synthesis, frozen-static Config B implementation, `pr_verify`, and bitstream generation are present.
- Cortex-A53/Vitis PCAP loader source is present.
- Conceptual questions are answered in `docs/conceptual_questions.md`.

## 1. Build the real Vivado block design

Create the ZCU102 design with:

- Zynq UltraScale+ MPSoC.
- `M_AXI_HPM0_FPD` enabled.
- `FCLK0 = 100 MHz`.
- AXI GPIO Channel 1 = 2-bit output (`decouple`, `rm_rst_n`).
- AXI GPIO Channel 2 = 32-bit heartbeat input.
- `heartbeat_ctr` in the static region.
- `u_pattern` as the Reconfigurable Partition.
- DFX Decoupler on `led[7:0]` with safe value `0x00`.

Validate the block design and create its HDL wrapper.

## 2. Create and verify the RP pblock

Apply the supplied pblock template, inspect it in Device view, and resolve all DFX DRCs. Save a screenshot showing the RP and pblock.

Do not assume the template clock region is legal until Vivado validates it on the actual implemented ZCU102 design.

## 3. Implement Configuration A

Route the full design with `pattern_chaser` in `u_pattern` and save:

- `build/config_a/routed.dcp`
- timing summary
- DRC report

## 4. Implement Configuration B from frozen static

Use `tcl/dfx_config_b_from_a.tcl` to preserve the static placement/routing and replace only `u_pattern` with the LFSR RM.

Save:

- `build/static_routed.dcp`
- `build/config_b/routed.dcp`
- timing summary

## 5. Run `pr_verify`

Run `tcl/verify_and_write_bitstreams.tcl`.

Required result: `pr_verify` PASS for the routed Config A and Config B checkpoints.

Do not use a partial bitstream on hardware if this verification fails.

## 6. Record bitstream sizes

Record exact byte sizes for:

- full chaser bitstream
- full LFSR bitstream
- partial chaser bitstream
- partial LFSR bitstream

Lab target: the two partial images should be close to each other in size and both much smaller than the full image. Record actual values rather than substituting estimates.

## 7. JTAG runtime swap

With the ZCU102 connected through JTAG:

1. Program the full chaser image.
2. Confirm the chaser pattern.
3. Record UART heartbeat and `hb_count`.
4. Assert reset/decouple as required.
5. Program the LFSR partial image.
6. Release reset and recouple.
7. Confirm the LFSR pattern.
8. Swap back to the chaser partial image.
9. Verify the heartbeat never pauses and `hb_count` remains monotonic.

Capture Hardware Manager and UART evidence.

## 8. PCAP runtime swap from Cortex-A53

Convert the matching partial image to the required binary form, place it in DDR at the address used by `vitis/main.c`, update `PARTIAL_SIZE_BYTES` to the exact generated size, and run the application.

Required handshake:

`RM reset -> decouple -> PCAP load -> release RM reset -> recouple`

Required evidence:

- XilFPGA success return.
- heartbeat delta across each swap.
- measured load time.
- repeated successful swaps in both directions.

## 9. Final quantitative evidence

Fill `docs/verification_checklist.md` with:

- exact bitstream sizes
- `pr_verify` result
- JTAG swap results
- UART continuity result
- heartbeat deltas
- PCAP success count
- PCAP min / max / mean time
- screenshots/log paths

The lab is fully complete only after these hardware-dependent items have real recorded evidence.
