/*******************************************************************************
* Module: hadamard_gate
* Description:  Hadamard quantum gate implementation
* 
* Matrix:  H = 1/√2 * [1   1]
*                    [1  -1]
*
* Transformation:  |ψ⟩ = α|0⟩ + β|1⟩  →  |ψ'⟩ = α'|0⟩ + β'|1⟩
*                 α' = (α + β)/√2
*                 β' = (α - β)/√2
*******************************************************************************/

module hadamard_gate (
    input  wire signed [31:0] alpha_in,   // Input α coefficient (Q16.16)
    input  wire signed [31:0] beta_in,    // Input β coefficient (Q16.16)
    output wire signed [31:0] alpha_out,  // Output α' coefficient (Q16.16)
    output wire signed [31:0] beta_out,   // Output β' coefficient (Q16.16)
    output wire               overflow    // Overflow indicator
);

    // Constants (Q16.16 format)
    localparam signed [31:0] INV_SQRT2 = 32'h0000_B505;  // 1/√2 ≈ 0.707107
    
    // Intermediate signals
    wire signed [31:0] sum;           // α + β
    wire signed [31:0] diff;          // α - β
    wire signed [31:0] alpha_temp;    // Before multiplication
    wire signed [31:0] beta_temp;     // Before multiplication
    
    wire overflow_sum, overflow_diff;
    wire overflow_mult_alpha, overflow_mult_beta;
    
    // Step 1: Calculate α + β
    fixed_point_add add_inst (
        .a(alpha_in),
        .b(beta_in),
        .sum(sum),
        .overflow(overflow_sum)
    );
    
    // Step 2: Calculate α - β
    wire signed [31:0] neg_beta;
    assign neg_beta = -beta_in;
    
    fixed_point_add sub_inst (
        .a(alpha_in),
        .b(neg_beta),
        .sum(diff),
        .overflow(overflow_diff)
    );
    
    // Step 3: Multiply by 1/√2
    fixed_point_mult mult_alpha (
        .a(sum),
        .b(INV_SQRT2),
        .product(alpha_out),
        .overflow(overflow_mult_alpha)
    );
    
    fixed_point_mult mult_beta (
        .a(diff),
        .b(INV_SQRT2),
        .product(beta_out),
        .overflow(overflow_mult_beta)
    );
    
    // Combine all overflow flags
    assign overflow = overflow_sum | overflow_diff | 
                      overflow_mult_alpha | overflow_mult_beta;

endmodule