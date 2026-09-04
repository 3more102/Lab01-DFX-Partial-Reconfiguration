`timescale 1ns / 1ps
module dfx_boundary_model (
    input  logic [7:0] rm_led,
    input  logic       decouple,
    output logic [7:0] led
);
    // Behavioral equivalent of the DFX decoupler safe value used in the lab.
    assign led = decouple ? 8'h00 : rm_led;
endmodule
