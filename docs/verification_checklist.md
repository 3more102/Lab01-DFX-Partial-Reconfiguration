# Lab verification checklist

Record only real evidence. Behavioral results below come from GitHub Actions; Vivado/Vitis/ZCU102 items remain TBD until executed on the required toolchain/hardware.

| Check | Target | Result / evidence |
|---|---|---|
| Behavioral testbench | No assertion/fatal errors | **PASS** — GitHub Actions `RTL CI` run #1, job `behavioral-simulation` |
| RTL compile | SystemVerilog compiles cleanly | **PASS** — Icarus Verilog compile step completed successfully |
| RM-A modeled behavior | Chaser activates | **PASS** — CI log: `RM-A active. LED=01 HB=14` |
| A -> B modeled swap | LFSR activates after swap | **PASS** — CI log: `RM-B active. LED=ac HB=180` |
| B -> A modeled swap | Chaser returns | **PASS** — CI log: `Reconfig complete. LED=01 HB=214` |
| Behavioral PASS marker | Explicit completion marker | **PASS** — `[TB] Behavioral Verification Passed!` |
| Behavioral decoupler | Boundary forced to `0x00` while decoupled | **PASS in model** — testbench assertion; hardware confirmation still required |
| Behavioral heartbeat | Monotonic through modeled swap windows | **PASS in model** — heartbeat advanced 14 -> 180 -> 214 |
| Config A routed | Chaser RM in `u_pattern` | **TBD — Vivado required** |
| Config B routed | LFSR RM in `u_pattern` | **TBD — Vivado required** |
| `pr_verify` | PASS | **TBD — Vivado required** |
| Full chaser bitstream size | Record bytes | TBD |
| Full LFSR bitstream size | Record bytes | TBD |
| Partial chaser size | Within expected RP-size class | TBD |
| Partial LFSR size | Near partial chaser size | TBD |
| JTAG swap A -> B | Pattern changes | **TBD — ZCU102 required** |
| JTAG swap B -> A | Pattern changes back | **TBD — ZCU102 required** |
| UART heartbeat | Zero pauses across hardware swaps | **TBD — ZCU102 required** |
| `hb_count` hardware rate | Monotonic, ~100 MHz rate | **TBD — ZCU102 required** |
| Hardware decoupler | LEDs = `0x00` while asserted | **TBD — ZCU102 required** |
| PCAP load | XilFPGA success | **TBD — Vitis/ZCU102 required** |
| PCAP stress | Repeated successful swaps | **TBD — Vitis/ZCU102 required** |
| PCAP timing | Record min / max / mean | **TBD — Vitis/ZCU102 required** |

## CI evidence

GitHub Actions run ID: `33891580227`

Observed behavioral log markers:

```text
[TB] Starting DFX Behavioral Verification...
[TB] RM-A active. LED=01 HB=14
[TB] Initiating A -> B reconfiguration sequence...
[TB] RM-B active. LED=ac HB=180
[TB] Reconfig complete. LED=01 HB=214
[TB] Behavioral Verification Passed!
```

## Hardware evidence to save

- `sim/xsim/xsim.log`
- `build/bitstreams/pr_verify.log`
- `build/config_a/timing_summary.rpt`
- `build/config_b/timing_summary.rpt`
- `build/config_a/drc.rpt` and `build/config_b/drc.rpt` if generated
- Screenshot of pblock and RP in Device view
- Screenshot of Hardware Manager programming each partial
- UART terminal log before/during/after swaps
- Vitis console showing PCAP times and heartbeat deltas

See `docs/remaining_hardware_steps.md` for the exact unfinished sequence.
