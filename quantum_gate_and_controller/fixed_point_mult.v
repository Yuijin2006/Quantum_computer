module fixed_point_mult (
    input  wire signed [31:0] a,        // Multiplicand (Q16.16)
    input  wire signed [31:0] b,        // Multiplier (Q16.16)
    output wire signed [31:0] product,  // Product (Q16.16)
    output wire               overflow  // Overflow flag
);

    // Internal 64-bit product
    wire signed [63:0] temp_product;
    
    // Perform multiplication
    assign temp_product = a * b;
    
    // Extract Q16.16 result (shift right by 16 bits)
    assign product = temp_product[47:16];
    
    // Overflow detection:  check if upper bits are non-zero
    assign overflow = (temp_product[63: 48] != 16'h0000) && 
                      (temp_product[63:48] != 16'hFFFF);

endmodule