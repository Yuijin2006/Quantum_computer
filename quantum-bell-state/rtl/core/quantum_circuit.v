/*******************************************************************************
* Module: quantum_circuit
* Description: Top-level quantum circuit for Bell state creation
* 
* Circuit:   |0⟩ ──H──●──
*           |0⟩ ─────⊕──
*
* Steps:
*   1. Initialize: |00⟩
*   2. Apply H to qubit 0: (|00⟩ + |10⟩)/√2
*   3. Apply CNOT(0,1): (|00⟩ + |11⟩)/√2  [Bell state Φ+]
*******************************************************************************/

module quantum_circuit (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,         // Start circuit execution
    
    output wire        done,          // Execution complete
    output wire [1:0]  state,         // FSM state
    
    // Final state amplitudes (Q16.16)
    output wire signed [31:0] state_00,
    output wire signed [31:0] state_01,
    output wire signed [31:0] state_10,
    output wire signed [31:0] state_11,
    
    // Debug outputs
    output wire signed [31:0] prob_00,  // |state_00|²
    output wire signed [31:0] prob_11   // |state_11|²
);

    // FSM states
    localparam IDLE    = 2'b00;
    localparam APPLY_H = 2'b01;
    localparam APPLY_CNOT = 2'b10;
    localparam DONE    = 2'b11;
    
    reg [1:0] current_state, next_state;
    
    // Constants
    localparam signed [31:0] FIXED_ONE  = 32'h0001_0000;
    localparam signed [31:0] FIXED_ZERO = 32'h0000_0000;
    
    // Qubit register signals
    reg        qreg_load;
    wire signed [31:0] qreg_00_in, qreg_01_in, qreg_10_in, qreg_11_in;
    wire signed [31:0] qreg_00_out, qreg_01_out, qreg_10_out, qreg_11_out;
    
    // Hadamard gate signals (applied to qubit 0)
    // For 2-qubit system:  H⊗I applied to |00⟩ and |10⟩
    wire signed [31:0] h_alpha_out, h_beta_out;
    wire h_overflow;
    
    // CNOT gate signals
    wire signed [31:0] cnot_00_out, cnot_01_out, cnot_10_out, cnot_11_out;
    
    // State outputs
    assign state_00 = qreg_00_out;
    assign state_01 = qreg_01_out;
    assign state_10 = qreg_10_out;
    assign state_11 = qreg_11_out;
    assign state = current_state;
    assign done = (current_state == DONE);
    
    // ========== Qubit Register ==========
    qubit_register qreg (
        .clk(clk),
        .rst_n(rst_n),
        .load(qreg_load),
        . state_00_in(qreg_00_in),
        .state_01_in(qreg_01_in),
        .state_10_in(qreg_10_in),
        .state_11_in(qreg_11_in),
        .state_00_out(qreg_00_out),
        .state_01_out(qreg_01_out),
        .state_10_out(qreg_10_out),
        .state_11_out(qreg_11_out)
    );
    
    // ========== Hadamard Gate (H ⊗ I) ==========
    // Apply H to first qubit:  affects |0⟩ and |1⟩ components
    // Input:   |00⟩ = 1|00⟩ + 0|10⟩
    // Output: (|00⟩ + |10⟩)/√2
    hadamard_gate h_gate (
        .alpha_in(qreg_00_out),   // Amplitude of |00⟩
        . beta_in(qreg_10_out),    // Amplitude of |10⟩
        . alpha_out(h_alpha_out),  // New amplitude of |00⟩
        .beta_out(h_beta_out),    // New amplitude of |10⟩
        .overflow(h_overflow)
    );
    
    // ========== CNOT Gate ==========
    cnot_gate cnot (
        .state_00_in(qreg_00_out),
        .state_01_in(qreg_01_out),
        .state_10_in(qreg_10_out),
        .state_11_in(qreg_11_out),
        .state_00_out(cnot_00_out),
        .state_01_out(cnot_01_out),
        .state_10_out(cnot_10_out),
        .state_11_out(cnot_11_out)
    );
    
    // ========== FSM:  State Register ==========
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end
    
    // ========== FSM: Next State Logic ==========
    always @(*) begin
        next_state = current_state;
        qreg_load = 1'b0;
        
        case (current_state)
            IDLE: begin
                if (start)
                    next_state = APPLY_H;
            end
            
            APPLY_H: begin
                qreg_load = 1'b1;
                next_state = APPLY_CNOT;
            end
            
            APPLY_CNOT:  begin
                qreg_load = 1'b1;
                next_state = DONE;
            end
            
            DONE: begin
                // Stay in DONE until reset
            end
        endcase
    end
    
    // ========== FSM:  Output Logic ==========
    assign qreg_00_in = (current_state == APPLY_H) ? h_alpha_out : cnot_00_out;
    assign qreg_01_in = (current_state == APPLY_H) ? FIXED_ZERO : cnot_01_out;
    assign qreg_10_in = (current_state == APPLY_H) ? h_beta_out : cnot_10_out;
    assign qreg_11_in = (current_state == APPLY_H) ? FIXED_ZERO : cnot_11_out;
    
    // ========== Probability Calculation ==========
    // |amplitude|² = amplitude × amplitude (for real numbers)
    wire ov_prob_00, ov_prob_11;
    
    fixed_point_mult prob_00_calc (
        .a(qreg_00_out),
        .b(qreg_00_out),
        .product(prob_00),
        .overflow(ov_prob_00)
    );
    
    fixed_point_mult prob_11_calc (
        .a(qreg_11_out),
        .b(qreg_11_out),
        .product(prob_11),
        .overflow(ov_prob_11)
    );

endmodule