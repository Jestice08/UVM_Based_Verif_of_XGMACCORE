# Create the library.
if [file exists work] {
    vdel -all
}
vlib work

# Compile the sources.
vlog ../dut/verilog/*.v +incdir+../dut/include/
vlog +cover -sv ../tb/*.sv 

# Simulate the design.
vsim -c mac_top
run -all
exit
