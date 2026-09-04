#include <stdio.h>
#include "xparameters.h"
#include "xgpio.h"
#include "xil_printf.h"
#include "xtime_l.h"
#include "xilfpga.h"
#include "xstatus.h"

#define GPIO_DEVICE_ID       XPAR_AXI_GPIO_0_DEVICE_ID
#define PARTIAL_BIN_ADDR     0x10000000U
/* Replace with the ACTUAL partial .bin file size before running. */
#define PARTIAL_SIZE_BYTES   0x00180000U

#define MASK_DECOUPLE        0x01U
#define MASK_RM_RST_N        0x02U

static XGpio Gpio;

static u32 read_heartbeat(void)
{
    return XGpio_DiscreteRead(&Gpio, 2);
}

static void set_dfx_ctrl(u32 decouple, u32 rm_rst_n)
{
    u32 reg_val = 0U;
    if (decouple != 0U) reg_val |= MASK_DECOUPLE;
    if (rm_rst_n != 0U) reg_val |= MASK_RM_RST_N;
    XGpio_DiscreteWrite(&Gpio, 1, reg_val);
}

int main(void)
{
    int status;
    XFpga fpga = {0};
    XTime t_start, t_end;
    u32 hb_start, hb_end;
    double elapsed_us;

    xil_printf("\r\n===================================\r\n");
    xil_printf(" ZCU102 DFX PCAP Swap Controller\r\n");
    xil_printf("===================================\r\n");

    status = XGpio_Initialize(&Gpio, GPIO_DEVICE_ID);
    if (status != XST_SUCCESS) {
        xil_printf("[ERROR] AXI GPIO init failed (%d)\r\n", status);
        return XST_FAILURE;
    }
    XGpio_SetDataDirection(&Gpio, 1, 0x00U);
    XGpio_SetDataDirection(&Gpio, 2, 0xFFFFFFFFU);
    set_dfx_ctrl(0U, 1U);

    xil_printf("[INIT] Static Region Alive. HB=%u\r\n", read_heartbeat());

    status = XFpga_Initialize(&fpga);
    if (status != XFPGA_SUCCESS) {
        xil_printf("[ERROR] XFpga_Initialize failed: 0x%08X\r\n", status);
        return XST_FAILURE;
    }

    for (int run = 1; run <= 5; ++run) {
        xil_printf("\r\n--- Starting DFX Swap #%d ---\r\n", run);
        hb_start = read_heartbeat();

        xil_printf("[STEP 1] Quiescing RM...\r\n");
        set_dfx_ctrl(0U, 0U);

        xil_printf("[STEP 2] Asserting decoupler...\r\n");
        set_dfx_ctrl(1U, 0U);

        xil_printf("[STEP 3] Loading partial via PCAP from 0x%08X...\r\n",
                   PARTIAL_BIN_ADDR);
        XTime_GetTime(&t_start);
        status = XFpga_BitStream_Load(&fpga,
                                      (UINTPTR)PARTIAL_BIN_ADDR,
                                      (UINTPTR)NULL,
                                      PARTIAL_SIZE_BYTES,
                                      XFPGA_PARTIAL_EN);
        XTime_GetTime(&t_end);

        if (status != XFPGA_SUCCESS) {
            xil_printf("[ERROR] PCAP partial load failed: 0x%08X\r\n", status);
            set_dfx_ctrl(0U, 1U);
            return XST_FAILURE;
        }

        elapsed_us = ((double)(t_end - t_start) * 1000000.0) /
                     (double)COUNTS_PER_SECOND;
        xil_printf("[SUCCESS] Partial load completed in %.2f us\r\n", elapsed_us);

        xil_printf("[STEP 4] Releasing RM reset...\r\n");
        set_dfx_ctrl(1U, 1U);

        xil_printf("[STEP 5] Recoupling boundary...\r\n");
        set_dfx_ctrl(0U, 1U);

        hb_end = read_heartbeat();
        xil_printf("[VERIFY] Heartbeat delta=%u ticks\r\n", hb_end - hb_start);
    }

    xil_printf("\r\n[DONE] All 5 PCAP swaps completed.\r\n");
    return XST_SUCCESS;
}
