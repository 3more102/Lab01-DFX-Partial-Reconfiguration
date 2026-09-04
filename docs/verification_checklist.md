# Lab verification checklist

Fill this with real evidence from Vivado/Vitis/ZCU102.

| Check | Target | Result / evidence |
|---|---|---|
| Behavioral testbench | No assertion/fatal errors | TBD |
| Config A routed | Chaser RM in `u_pattern` | TBD |
| Config B routed | LFSR RM in `u_pattern` | TBD |
| `pr_verify` | PASS | TBD |
| Full chaser bitstream size | Record bytes | TBD |
| Full LFSR bitstream size | Record bytes | TBD |
| Partial chaser size | Within expected RP-size class | TBD |
| Partial LFSR size | Near partial chaser size | TBD |
| JTAG swap A -> B | Pattern changes | TBD |
| JTAG swap B -> A | Pattern changes back | TBD |
| UART heartbeat | Zero pauses across swaps | TBD |
| `hb_count` | Monotonic, ~100 MHz rate | TBD |
| Decoupler | LEDs = `0x00` while asserted | TBD |
| PCAP load | `XFPGA_SUCCESS` | TBD |
| PCAP stress | Repeated successful swaps | TBD |
| PCAP timing | Record min / max / mean | TBD |

## Evidence to save
- `sim/xsim/xsim.log`
- `build/bitstreams/pr_verify.log`
- `build/config_a/timing_summary.rpt`
- `build/config_b/timing_summary.rpt`
- `build/config_a/drc.rpt` and `build/config_b/drc.rpt` if generated
- Screenshot of pblock and RP in Device view
- Screenshot of Hardware Manager programming each partial
- UART terminal log before/during/after swaps
- Vitis console showing PCAP times and heartbeat deltas
