# Create the library.
if [file exists work] {
    vdel -all
}
vlib work

# Compile the sources.
vlog ../dut/verilog/*.v +incdir+../dut/include/
vlog +cover -sv  ../tb/mac_interface.sv ../tb/rst_sequence.sv ../tb/wb_sequence.sv  ../tb/tx_sequence.sv ../tb/tx_driver.sv  ../tb/tx_monitor.sv  ../tb/rx_monitor.sv  ../tb/rst_modules.sv  ../tb/wb_modules.sv  ../tb/tx_agent.sv  ../tb/rx_agent.sv  ../tb/scoreboard.sv  ../tb/mac_env.sv  ../tb/virtual_sequencer.sv  ../tb/testclass.sv  ../tb/mac_test_top.sv -override_timescale 1ps/1ps


# Simulate the design.
vsim -c xge_test_top  
run -all
exit
