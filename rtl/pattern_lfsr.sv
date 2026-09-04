module pattern_lfsr (
    input  logic       clk,
    input  logic       rst_n,
    output logic [7:0] led
);
    logic [27:0] div;
    logic [7:0]  lfsr;
    logic        feedback;

    assign feedback = lfsr[7] ^ lfsr[5] ^ lfsr[4] ^ lfsr[3];

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            div  <= '0;
            lfsr <= 8'hAC;
            // The PDF resets the LFSR but not led. Initializing led here avoids
            // an X-valued output until the first divider event in simulation.
            led  <= 8'hAC;
        end else begin
            div <= div + 1'b1;
            if (div[21]) begin
                div  <= '0;
                lfsr <= {lfsr[6:0], feedback};
                led  <= lfsr;
            end
        end
    end
endmodule
