/*******************************************************************************
* Testbench:  tb_hadamard
* Description:  Test Hadamard gate with various inputs
*******************************************************************************/

`timescale 1ns/1ps

module tb_hadamard;

    // Signals
    reg  signed [31:0] alpha_in;
    reg  signed [31:0] beta_in;
    wire signed [31:0] alpha_out;
    wire signed [31:0] beta_out;
    wire overflow;
    
    // Fixed-point constants
    localparam signed [31:0] FIXED_ONE  = 32'h0001_0000;  // 1.0
    localparam signed [31:0] FIXED_ZERO = 32'h0000_0000;  // 0.0
    localparam signed [31:0] INV_SQRT2  = 32'h0000_B505;  // 0.707107
    
    // Conversion function
    function real fp_to_real;
        input [31:0] fp;
        begin
            fp_to_real = $itor($signed(fp)) / 65536.0;
        end
    endfunction
    
    // DUT instantiation
    hadamard_gate dut (
        .alpha_in(alpha_in),
        .beta_in(beta_in),
        .alpha_out(alpha_out),
        .beta_out(beta_out),
        .overflow(overflow)
    );
    
    // Test stimulus
    initial begin
        $display("========================================");
        $display("  Hadamard Gate Test");
        $display("========================================");
        $display("Time\tInput(α,β)\t\tOutput(α',β')\t\tOverflow");
        $display("------------------------------------------------------------------------");
        
        // Test 1: H|0⟩ = (|0⟩ + |1⟩)/√2
        alpha_in = FIXED_ONE;
        beta_in = FIXED_ZERO;
        #10;
        $display("%0t\t(%.3f, %.3f)\t\t(%.3f, %.3f)\t%b",
                 $time, 
                 fp_to_real(alpha_in), fp_to_real(beta_in),
                 fp_to_real(alpha_out), fp_to_real(beta_out),
                 overflow);
        
        // Test 2: H|1⟩ = (|0⟩ - |1⟩)/√2
        alpha_in = FIXED_ZERO;
        beta_in = FIXED_ONE;
        #10;
        $display("%0t\t(%.3f, %.3f)\t\t(%.3f, %.3f)\t%b",
                 $time,
                 fp_to_real(alpha_in), fp_to_real(beta_in),
                 fp_to_real(alpha_out), fp_to_real(beta_out),
                 overflow);
        
        // Test 3: H(H|0⟩) = |0⟩ (should return to original)
        alpha_in = INV_SQRT2;
        beta_in = INV_SQRT2;
        #10;
        $display("%0t\t(%.3f, %.3f)\t\t(%.3f, %.3f)\t%b",
                 $time,
                 fp_to_real(alpha_in), fp_to_real(beta_in),
                 fp_to_real(alpha_out), fp_to_real(beta_out),
                 overflow);
        
        $display("========================================");
        $display("  Test Complete");
        $display("========================================\n");
        $finish;
    end

endmodule