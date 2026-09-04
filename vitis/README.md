# Vitis PCAP application

The supplied PDF uses `XFpga_PartialBtcnfg()`. Current XilFPGA headers expose
`XFpga_BitStream_Load()` with `XFPGA_PARTIAL_EN`; this project uses that public
API so it matches modern embeddedsw/XilFPGA.

Before running:
1. Build/export the hardware platform and create a standalone A53 application.
2. Enable/include the XilFPGA BSP library.
3. Convert the partial bitstream to `.bin` as required by your flow, or use a
   supported `.bit` image according to your BSP/library version.
4. Put the image at `0x10000000` in DDR.
5. Replace `PARTIAL_SIZE_BYTES` with the exact image size.
6. Start from the matching static full bitstream.
