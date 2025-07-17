#!/bin/bash

# Usage: ./run_modelsim.sh "pathtoDUT" "pathtoTB"


# Set arguments 1 and 2 to DUT and TB

# if [$# -ne 2]; then
#	echo "Usage: $0 <DUT_file> <Testbench_file>"
#	exit 1
# fi

# DUT_FILE=$(realpath "$1")
# TB_FILE=$(realpath "$2")

RUN_MODELSIM="/mnt/c/intelFPGA/18.1/modelsim_ase/win32aloem/modelsim.exe"

"$RUN_MODELSIM" #"$DUT_FILE" "$TB_FILE"







