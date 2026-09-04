# Lab01 — DFX Partial Reconfiguration on ZCU102

Engineering-ready source package derived from the supplied lab **“DFX: Runtime Module Swap on ZCU102.”**

## Objective
Keep a static Zynq UltraScale+ MPSoC design alive while swapping one Reconfigurable Partition (RP) between two Reconfigurable Modules (RMs):

- **RM-A — `pattern_chaser`**: one-hot LED chaser
- **RM-B — `pattern_lfsr`**: 8-bit LFSR pseudo-random pattern

The static region contains the PS-facing AXI GPIO and a free-running 32-bit heartbeat counter. A DFX Decoupler holds `led[7:0]` at `0x00` while the RP is being reconfigured.

## Target
- Board: **AMD/Xilinx ZCU102**
- Device: **XCZU9EG-2FFVB1156E**
- Lab toolchain: **Vivado / Vitis 2023.2**
- Fabric clock: **100 MHz FCLK0**

## Repository layout
```text
.github/workflows/ RTL behavioral CI
rtl/               Static logic, RM-A, RM-B, decoupler model
tb/                Behavioral DFX sequencing testbench
constr/             ZCU102 LED constraints
tcl/                Vivado simulation, OOC RM, DFX and bitstream scripts
vitis/              A53 XilFPGA/PCAP partial loader
docs/               Implementation notes, traceability, verification checklist
sim/                Generated simulation outputs (ignored)
build/              Generated Vivado/DFX outputs (ignored)
```

## 1. Behavioral verification
### Vivado XSIM
From a Vivado 2023.2 shell:
```bash
vivado -mode batch -source tcl/run_behavioral_sim.tcl
```

### Icarus Verilog / CI
```bash
./run_all_possible_checks.sh
```

The testbench models:
1. RM reset + boundary decouple.
2. RM-A activation.
3. A -> B runtime swap window.
4. RM-B activation from seed `0xAC`.
5. B -> A return swap.
6. Heartbeat continuity across both modeled swaps.

Expected final marker:
```text
[TB] Behavioral Verification Passed!
```

## 2. Create the Vivado source project
```bash
vivado -mode batch -source tcl/create_project_skeleton.tcl
```

Then complete the block design as specified by the lab:
1. Add Zynq UltraScale+ MPSoC and run board automation.
2. Enable `M_AXI_HPM0_FPD`; set `FCLK0 = 100 MHz`.
3. Add AXI GPIO: Channel 1 output width 2; Channel 2 input width 32.
4. Add `heartbeat_ctr` and connect `count` to GPIO Channel 2.
5. Add `pattern_chaser` as module reference named `u_pattern`.
6. Connect `clk = FCLK0`, `rst_n = dfx_ctrl[1]`, export `led[7:0]`.
7. Use the DFX Wizard to make `u_pattern` the RP and insert a DFX Decoupler on `led` with safe value `0x00`.
8. Connect decoupler control to `dfx_ctrl[0]`.
9. Validate the design and create the HDL wrapper.

## 3. Floorplan the RP
With the synthesized/implemented design open:
```tcl
source tcl/pblock_template.tcl
```

The supplied lab uses `CLOCKREGION_X1Y2`. Confirm legality on the actual ZCU102 design and resolve all DFX DRCs before implementation.

## 4. Build both RM synthesis checkpoints
```bash
vivado -mode batch -source tcl/build_rm_dcps.tcl
```

Expected outputs:
```text
build/rm/pattern_chaser_synth.dcp
build/rm/pattern_lfsr_synth.dcp
```

## 5. Implement Configuration A
Implement the complete design with `pattern_chaser` resident in `u_pattern`, then save:
```tcl
file mkdir build/config_a
write_checkpoint -force build/config_a/routed.dcp
report_timing_summary -file build/config_a/timing_summary.rpt
report_drc -file build/config_a/drc.rpt
```

## 6. Implement Configuration B from frozen static
```bash
vivado -mode batch -source tcl/dfx_config_b_from_a.tcl
```

The script follows the DFX preservation sequence:
```text
Config A routed DCP
  -> black-box u_pattern
  -> lock static routing
  -> save static_routed.dcp
  -> insert RM-B
  -> opt/place/route
  -> Config B routed DCP
```

## 7. Verify compatibility and generate bitstreams
```bash
vivado -mode batch -source tcl/verify_and_write_bitstreams.tcl
```

Expected outputs:
```text
build/bitstreams/full_chaser.bit
build/bitstreams/full_lfsr.bit
build/bitstreams/partial_chaser.bit
build/bitstreams/partial_lfsr.bit
build/bitstreams/pr_verify.log
```

**Do not program a partial image unless `pr_verify` passes for the matching Config A / Config B routed checkpoints.**

## 8. JTAG runtime test
1. Program `full_chaser.bit`.
2. Verify chaser LEDs and UART/heartbeat continuity.
3. Assert decouple; LEDs must become `0x00`.
4. Load `partial_lfsr.bit` using Hardware Manager.
5. Release RM reset and recouple; verify LFSR behavior.
6. Swap back using `partial_chaser.bit`.
7. Record `hb_count` before/after each swap.

## 9. PCAP partial load from Cortex-A53
Use `vitis/main.c`. Put the matching partial image in DDR at `0x10000000`, replace `PARTIAL_SIZE_BYTES` with the exact image size, and run the application.

Runtime handshake:
```text
RM reset -> decouple -> partial load -> RM reset release -> recouple
```

The app records partial-load time and heartbeat delta.

## Verification evidence to capture
Use `docs/verification_checklist.md` and record real values for:
- Behavioral simulation PASS.
- Config A / Config B routed successfully.
- `pr_verify` PASS.
- Exact full and partial image sizes.
- JTAG swaps in both directions.
- Zero UART heartbeat pauses.
- Monotonic `hb_count` across every swap.
- Decoupled output = `0x00`.
- PCAP result = `XFPGA_SUCCESS` for repeated loads.
- Min / max / mean PCAP load time.

## Accuracy notes
`docs/implementation_notes.md` lists the small executable corrections made relative to the supplied PDF, including the static-lock sequence, `pr_verify` usage, XilFPGA API choice, simulation initialization, and the divider timing interpretation.

## Current validation status
- Source/package integrity: **checked**
- Local RTL simulation in this environment: **not executed** (no simulator available here)
- Vivado DFX implementation: **requires Vivado 2023.2 + board/IP/license**
- ZCU102 hardware proof: **requires physical ZCU102**

No bitstream or hardware PASS result is claimed until it is produced on the required toolchain and board.
