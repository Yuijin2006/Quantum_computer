/*******************************************************************************
* Module:  cnot_gate
* Description:  CNOT (Controlled-NOT) quantum gate for 2-qubit system
* 
* Matrix:  CNOT = [1 0 0 0]
*                [0 1 0 0]
*                [0 0 0 1]
*                [0 0 1 0]
*
* For Bell state creation after H gate:
*   Input:   |ψ⟩ = (|0⟩ + |1⟩)/√2 ⊗ |0⟩ = (|00⟩ + |10⟩)/√2
*   Output: |ψ'⟩ = (|00⟩ + |11⟩)/√2  [Bell state Φ+]
*
* State encoding:
*   |00⟩ → state_00
*   |01⟩ → state_01
*   |10⟩ → state_10
*   |11⟩ → state_11
*******************************************************************************/

module cnot_gate (
    // Input state amplitudes (Q16.16)
    input  wire signed [31:0] state_00_in,
    input  wire signed [31:0] state_01_in,
    input  wire signed [31:0] state_10_in,
    input  wire signed [31:0] state_11_in,
    
    // Output state amplitudes (Q16.16)
    output wire signed [31:0] state_00_out,
    output wire signed [31:0] state_01_out,
    output wire signed [31:0] state_10_out,
    output wire signed [31:0] state_11_out
);

    // CNOT transformation: 
    // |00⟩ → |00⟩  (control=0, target unchanged)
    // |01⟩ → |01⟩  (control=0, target unchanged)
    // |10⟩ → |11⟩  (control=1, flip target)
    // |11⟩ → |10⟩  (control=1, flip target)
    
    assign state_00_out = state_00_in;  // |00⟩ stays
    assign state_01_out = state_01_in;  // |01⟩ stays
    assign state_10_out = state_11_in;  // |10⟩ ↔ |11⟩ swap
    assign state_11_out = state_10_in;  // |11⟩ ↔ |10⟩ swap

endmodule