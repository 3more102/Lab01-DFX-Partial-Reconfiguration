`timescale 1ns/1ps

module tb_dfx_behavior;
    logic clk = 1'b0;
    logic rm_rst_n = 1'b0;
    logic decouple = 1'b0;
    logic select_lfsr = 1'b0;
    logic [7:0] chaser_led;
    logic [7:0] lfsr_led;
    logic [7:0] rm_led;
    logic [7:0] decoupled_led;
    logic [31:0] hb_count;
    logic [31:0] hb_before_swap;

    always #5 clk = ~clk; // 100 MHz

    heartbeat_ctr u_hb (
        .clk   (clk),
        .count (hb_count)
    );

    pattern_chaser u_rm_a (
        .clk   (clk),
        .rst_n (rm_rst_n),
        .led   (chaser_led)
    );

    pattern_lfsr u_rm_b (
        .clk   (clk),
        .rst_n (rm_rst_n),
        .led   (lfsr_led)
    );

    // Behavioral stand-in for which RM is currently resident in the RP.
    // This mux is simulation-only; hardware DFX physically rewrites the RP.
    assign rm_led = select_lfsr ? lfsr_led : chaser_led;

    dfx_boundary_model u_boundary (
        .rm_led    (rm_led),
        .decouple  (decouple),
        .led       (decoupled_led)
    );

    initial begin
        $display("[TB] Starting DFX Behavioral Verification...");

        // 1) Safe startup: RP reset and boundary decoupled.
        decouple = 1'b1;
        rm_rst_n = 1'b0;
        select_lfsr = 1'b0;
        #100;
        assert (decoupled_led == 8'h00)
            else $fatal(1, "[TB ERROR] LEDs not zero while decoupled");

        // 2) Start RM-A (chaser).
        rm_rst_n = 1'b1;
        #20;
        decouple = 1'b0;
        #20;
        assert (decoupled_led == 8'h01)
            else $fatal(1, "[TB ERROR] Chaser did not start at one-hot 0x01");
        $display("[TB] RM-A active. LED=%02h HB=%0d", decoupled_led, hb_count);

        // 3) Prove the static heartbeat is alive before the swap.
        #1000;
        assert (hb_count > 32'd100)
            else $fatal(1, "[TB ERROR] Heartbeat counter stalled before swap");
        hb_before_swap = hb_count;

        // 4) Model runtime swap A -> B using the required protection window.
        $display("[TB] Initiating A -> B reconfiguration sequence...");
        rm_rst_n = 1'b0;     // quiesce RM
        decouple = 1'b1;     // protect boundary
        #100;
        assert (decoupled_led == 8'h00)
            else $fatal(1, "[TB ERROR] Boundary not held at safe value");

        // Represents the partial-bitstream load interval.
        #500;
        select_lfsr = 1'b1;
        #20;
        assert (decoupled_led == 8'h00)
            else $fatal(1, "[TB ERROR] Glitch during modeled partial load");

        rm_rst_n = 1'b1;     // initialize new RM
        #20;
        decouple = 1'b0;     // expose new RM
        #20;
        assert (decoupled_led == 8'hAC)
            else $fatal(1, "[TB ERROR] LFSR RM did not start from seed 0xAC");
        assert (hb_count > hb_before_swap)
            else $fatal(1, "[TB ERROR] Static heartbeat lost continuity during swap");
        $display("[TB] RM-B active. LED=%02h HB=%0d", decoupled_led, hb_count);

        // 5) Swap B -> A to prove repeatability of the sequence model.
        hb_before_swap = hb_count;
        rm_rst_n = 1'b0;
        decouple = 1'b1;
        #300;
        select_lfsr = 1'b0;
        rm_rst_n = 1'b1;
        #20;
        decouple = 1'b0;
        #20;
        assert (decoupled_led == 8'h01)
            else $fatal(1, "[TB ERROR] Chaser RM did not restore correctly");
        assert (hb_count > hb_before_swap)
            else $fatal(1, "[TB ERROR] Heartbeat lost continuity on return swap");

        $display("[TB] Reconfig complete. LED=%02h HB=%0d", decoupled_led, hb_count);
        $display("[TB] Behavioral Verification Passed!");
        $finish;
    end
endmodule
