/*******************************************************************************
* Module: qubit_register
* Description: Register to store quantum state (2-qubit system)
* 
* Stores 4 complex amplitudes for 2-qubit basis states: 
*   |ψ⟩ = a|00⟩ + b|01⟩ + c|10⟩ + d|11⟩
*******************************************************************************/

module qubit_register (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        load,          // Load enable
    
    // Input state
    input  wire signed [31:0] state_00_in,
    input  wire signed [31:0] state_01_in,
    input  wire signed [31:0] state_10_in,
    input  wire signed [31:0] state_11_in,
    
    // Output state
    output reg  signed [31:0] state_00_out,
    output reg  signed [31:0] state_01_out,
    output reg  signed [31:0] state_10_out,
    output reg  signed [31:0] state_11_out
);

    // Constants (Q16.16)
    localparam signed [31:0] FIXED_ONE  = 32'h0001_0000;  // 1.0
    localparam signed [31:0] FIXED_ZERO = 32'h0000_0000;  // 0.0

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset to |00⟩ state
            state_00_out <= FIXED_ONE;
            state_01_out <= FIXED_ZERO;
            state_10_out <= FIXED_ZERO;
            state_11_out <= FIXED_ZERO;
        end else if (load) begin
            // Load new state
            state_00_out <= state_00_in;
            state_01_out <= state_01_in;
            state_10_out <= state_10_in;
            state_11_out <= state_11_in;
        end
        // else: hold current state
    end

endmodule