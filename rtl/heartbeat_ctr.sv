`timescale 1ns / 1ps
module heartbeat_ctr (
    input  logic        clk,
    output logic [31:0] count = 32'd0
);
    // Static-region heartbeat. Explicit initialization is used so the
    // behavioral testbench can prove monotonic counting from time zero.
    always_ff @(posedge clk)
        count <= count + 32'd1;
endmodule
