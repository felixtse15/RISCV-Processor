#!/bin/bash
# Copyright 2025 Felix Tse
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0


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
