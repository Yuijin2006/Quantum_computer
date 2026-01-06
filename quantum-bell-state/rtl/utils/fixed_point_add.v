module fixed_point_add (
    input  wire signed [31:0] a,        // Operand A (Q16.16)
    input  wire signed [31:0] b,        // Operand B (Q16.16)
    output reg  signed [31:0] sum,      // Sum (Q16.16)
    output reg                overflow  // Overflow flag
);

    wire signed [32:0] temp_sum;
    
    // 33-bit addition to detect overflow
    assign temp_sum = {a[31], a} + {b[31], b};
    
    always @(*) begin
        // Check for overflow
        if (temp_sum[32] != temp_sum[31]) begin
            // Overflow occurred - saturate
            overflow = 1'b1;
            if (temp_sum[32]) begin
                // Negative overflow
                sum = 32'h80000000;  // Most negative value
            end else begin
                // Positive overflow
                sum = 32'h7FFFFFFF;  // Most positive value
            end
        end else begin
            // No overflow
            overflow = 1'b0;
            sum = temp_sum[31:0];
        end
    end

endmodule