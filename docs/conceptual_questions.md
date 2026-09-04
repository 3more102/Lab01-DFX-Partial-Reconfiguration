# Conceptual Questions — Lab 1 DFX

These answers correspond to the four conceptual questions at the end of the supplied Lab 1 PDF.

## 1. Why are both partial bitstreams nearly the same size?

A partial bitstream programs configuration **frames that belong to the Reconfigurable Partition (RP)**. The amount of configuration data is therefore driven mainly by the physical footprint of the RP/pblock rather than by the number of LUTs or flip-flops used by a particular Reconfigurable Module (RM).

`pattern_chaser` and `pattern_lfsr` occupy the same RP and use the same interface, so their partial bitstreams should be close in size even though their internal logic differs.

If the pblock were enlarged while keeping the RM logic unchanged, the partial bitstream would also grow because more configuration frames would belong to that reconfigurable region. The exact byte relationship can include bitstream-format overhead, so the lab requires measuring the real generated files rather than assuming a precise factor.

## 2. Why must clocks, resets, and PS interfaces remain in the static region?

The RP is temporarily unavailable and its configuration state is being rewritten during a partial reconfiguration. Infrastructure required by the rest of the design therefore must not depend on logic that is being replaced.

The 100 MHz FCLK, reset/control path, AXI infrastructure, PS interface, GPIO control and heartbeat observation belong in the static region so they remain valid throughout the swap.

If the 100 MHz clock buffer were placed inside the RP, the clock path itself could disappear or become undefined while the RP frames were rewritten. Logic relying on that clock could stall or behave unpredictably, defeating the lab requirement that the static region continue uninterrupted.

## 3. Why is a partial bitstream tied to one static implementation?

The partial image is generated against a particular routed static design and RP boundary. The partition interface and the preserved static placement/routing must remain compatible with the implementation against which that partial was created.

Loading a partial generated from a different static implementation risks a mismatch at the RP/static boundary or differences in preserved routing/configuration context. That can make the resulting hardware invalid even if the RM source code looks compatible.

The lab therefore uses `pr_verify` on the routed checkpoints before generating/programming partial images. `pr_verify` is the compatibility check intended to catch static-region or partition-boundary implementation differences between configurations.

## 4. How can PCAP configuration-frame time be separated from fixed software overhead?

Use the same software path and RM while generating several legal RP/pblock sizes. For each case:

1. Generate the partial bitstream and record its exact byte size.
2. Load it repeatedly through the same PCAP application.
3. Record min/mean/max elapsed time with the same timer code.
4. Plot or fit measured time versus partial-bitstream size.

A useful first-order model is:

`T_total = T_fixed + (partial_bytes / effective_transfer_bandwidth)`

The intercept estimates fixed software/driver/CSU setup overhead, while the slope estimates the size-dependent configuration transfer time. Repeating each size multiple times reduces measurement noise.

This directly tests the lab's point that configuration work scales with the RP's configuration-frame footprint while the application also contains fixed PCAP/software overhead.
