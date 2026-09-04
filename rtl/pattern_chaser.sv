`timescale 1ns / 1ps
module pattern_chaser (
    input  logic       clk,
    input  logic       rst_n,
    output logic [7:0] led
);
    logic [27:0] div;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            div <= '0;
            led <= 8'b0000_0001;
        end else begin
            div <= div + 1'b1;
            if (div[21]) begin
                div <= '0;
                led <= {led[6:0], led[7]};
            end
        end
    end
endmodule
