/*******************************************************************************
* Testbench: tb_cnot
* Description: Test CNOT gate transformations
*******************************************************************************/

`timescale 1ns/1ps

module tb_cnot;

    // Signals
    reg  signed [31:0] state_00_in, state_01_in, state_10_in, state_11_in;
    wire signed [31:0] state_00_out, state_01_out, state_10_out, state_11_out;
    
    // Constants
    localparam signed [31:0] FIXED_ONE  = 32'h0001_0000;
    localparam signed [31:0] FIXED_ZERO = 32'h0000_0000;
    localparam signed [31:0] INV_SQRT2  = 32'h0000_B505;
    
    function real fp_to_real;
        input [31:0] fp;
        fp_to_real = $itor($signed(fp)) / 65536.0;
    endfunction
    
    // DUT
    cnot_gate dut (
        .state_00_in(state_00_in),
        .state_01_in(state_01_in),
        .state_10_in(state_10_in),
        .state_11_in(state_11_in),
        .state_00_out(state_00_out),
        .state_01_out(state_01_out),
        .state_10_out(state_10_out),
        .state_11_out(state_11_out)
    );
    
    initial begin
        $display("========================================");
        $display("  CNOT Gate Test");
        $display("========================================\n");
        
        // Test 1: CNOT|00⟩ = |00⟩
        $display("Test 1: CNOT|00⟩ = |00⟩");
        state_00_in = FIXED_ONE;
        state_01_in = FIXED_ZERO;
        state_10_in = FIXED_ZERO;
        state_11_in = FIXED_ZERO;
        #10;
        $display("Input:   |00⟩=%.3f |01⟩=%.3f |10⟩=%.3f |11⟩=%. 3f",
                 fp_to_real(state_00_in), fp_to_real(state_01_in),
                 fp_to_real(state_10_in), fp_to_real(state_11_in));
        $display("Output: |00⟩=%.3f |01⟩=%.3f |10⟩=%.3f |11⟩=%.3f\n",
                 fp_to_real(state_00_out), fp_to_real(state_01_out),
                 fp_to_real(state_10_out), fp_to_real(state_11_out));
        
        // Test 2: CNOT|10⟩ = |11⟩
        $display("Test 2: CNOT|10⟩ = |11⟩");
        state_00_in = FIXED_ZERO;
        state_01_in = FIXED_ZERO;
        state_10_in = FIXED_ONE;
        state_11_in = FIXED_ZERO;
        #10;
        $display("Input:  |00⟩=%.3f |01⟩=%.3f |10⟩=%. 3f |11⟩=%.3f",
                 fp_to_real(state_00_in), fp_to_real(state_01_in),
                 fp_to_real(state_10_in), fp_to_real(state_11_in));
        $display("Output: |00⟩=%. 3f |01⟩=%.3f |10⟩=%.3f |11⟩=%.3f\n",
                 fp_to_real(state_00_out), fp_to_real(state_01_out),
                 fp_to_real(state_10_out), fp_to_real(state_11_out));
        
        // Test 3: Bell state input (|00⟩ + |10⟩)/√2 → (|00⟩ + |11⟩)/√2
        $display("Test 3: Bell state creation");
        state_00_in = INV_SQRT2;
        state_01_in = FIXED_ZERO;
        state_10_in = INV_SQRT2;
        state_11_in = FIXED_ZERO;
        #10;
        $display("Input:   |00⟩=%. 3f |01⟩=%.3f |10⟩=%.3f |11⟩=%.3f",
                 fp_to_real(state_00_in), fp_to_real(state_01_in),
                 fp_to_real(state_10_in), fp_to_real(state_11_in));
        $display("Output: |00⟩=%.3f |01⟩=%.3f |10⟩=%.3f |11⟩=%.3f\n",
                 fp_to_real(state_00_out), fp_to_real(state_01_out),
                 fp_to_real(state_10_out), fp_to_real(state_11_out));
        
        $display("========================================");
        $display("  Test Complete");
        $display("========================================\n");
        $finish;
    end

endmodule