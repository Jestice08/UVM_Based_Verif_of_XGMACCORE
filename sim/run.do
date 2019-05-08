# Create the library.
if [file exists work] {
    vdel -all
}
vlib work

# Compile the sources.
vlog ../dut/verilog/*.v ../dut/include/*.v
vlog +cover -sv ../tb/*.sv 

# Simulate the design.
vsim -c mac_top
run -all
exit