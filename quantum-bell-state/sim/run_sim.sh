#!/bin/bash

################################################################################
# Simulation Script for Bell State Circuit
################################################################################

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "================================================================================"
echo "  Quantum Bell State Circuit Simulation"
echo "================================================================================"

# Check if Icarus Verilog is installed
if ! command -v iverilog &> /dev/null; then
    echo -e "${RED}ERROR: Icarus Verilog (iverilog) not found!${NC}"
    echo "Please install it using: sudo apt-get install iverilog"
    exit 1
fi

# Create output directory
mkdir -p output
cd output

echo -e "\n${YELLOW}[1/5]${NC} Testing Hadamard Gate..."
iverilog -g2012 -o tb_hadamard.vvp \
    ../rtl/utils/fixed_point_add.v \
    ../rtl/utils/fixed_point_mult.v \
    ../rtl/gates/hadamard_gate.v \
    ../tb/tb_hadamard.v

if [ $? -eq 0 ]; then
    vvp tb_hadamard. vvp
    echo -e "${GREEN}✓ Hadamard test passed${NC}"
else
    echo -e "${RED}✗ Hadamard test failed${NC}"
    exit 1
fi

echo -e "\n${YELLOW}[2/5]${NC} Testing CNOT Gate..."
iverilog -g2012 -o tb_cnot.vvp \
    ../rtl/gates/cnot_gate.v \
    ../tb/tb_cnot.v

if [ $?  -eq 0 ]; then
    vvp tb_cnot.vvp
    echo -e "${GREEN}✓ CNOT test passed${NC}"
else
    echo -e "${RED}✗ CNOT test failed${NC}"
    exit 1
fi

echo -e "\n${YELLOW}[3/5]${NC} Compiling Full Circuit..."
iverilog -g2012 -o tb_bell_state.vvp \
    ../rtl/utils/fixed_point_add.v \
    ../rtl/utils/fixed_point_mult.v \
    ../rtl/gates/hadamard_gate.v \
    ../rtl/gates/cnot_gate.v \
    ../rtl/core/qubit_register.v \
    ../rtl/core/quantum_circuit.v \
    ../tb/tb_bell_state. v

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Compilation successful${NC}"
else
    echo -e "${RED}✗ Compilation failed${NC}"
    exit 1
fi

echo -e "\n${YELLOW}[4/5]${NC} Running Bell State Simulation..."
vvp tb_bell_state.vvp

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Simulation completed${NC}"
else
    echo -e "${RED}✗ Simulation failed${NC}"
    exit 1
fi

echo -e "\n${YELLOW}[5/5]${NC} Generating Reports..."
if [ -f "bell_state_result. txt" ]; then
    echo -e "${GREEN}✓ Log file generated: output/bell_state_result.txt${NC}"
fi

if [ -f "bell_state.vcd" ]; then
    echo -e "${GREEN}✓ Waveform file generated: output/bell_state.vcd${NC}"
fi

echo ""
echo "================================================================================"
echo "  Simulation Complete!"
echo "================================================================================"
echo ""
echo "View results:"
echo "  • Text log:   cat output/bell_state_result. txt"
echo "  • Waveform:   gtkwave output/bell_state. vcd"
echo ""

cd ..