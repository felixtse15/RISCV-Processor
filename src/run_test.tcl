foreach i {1 2 3 4 5 6 7 8 9 10} {
    set memfile "D:/projects/RISCV/tools/input/input_$i.txt"
    vlog -work work ../src/*.sv
    vsim -c work.rvsimtb +memfile=$memfile -do "run -all; quit"
}
