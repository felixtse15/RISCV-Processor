#!/bin/bash

# how many tests to run
x=10

# Paths
TOOLS_DIR="/mnt/d/projects/RISCV/tools"
IN_DIR="$TOOLS_DIR/input"
INLOG_DIR="$TOOLS_DIR/input_log"
OUT_DIR="$TOOLS_DIR/output"
REF_DIR="$TOOLS_DIR/reference"

# Generate instruction files and save console output for reference
"$TOOLS_DIR/instr_gen.py" > "$INLOG_DIR/log_input.txt"

(for ((i = 1; i <= x; i++)); do
    echo "Run #$i"
 
    # Evaluate using main and save output
    "$REF_DIR/main" "$IN_DIR/input_$i.txt" > "$OUT_DIR/output_$i.txt"
done) 
