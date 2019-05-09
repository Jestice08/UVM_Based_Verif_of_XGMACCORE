# Create the library.
if [file exists work] {
    vdel -all
}
vlib work

# Compile the sources.
vlog ../dut/verilog/*.v +incdir+../dut/include/
vlog +cover -sv ../tb/mac_package.sv  ../tb/mac_interface.sv ../tb/rst_seq_item.sv  ../tb/wb_seq_item.sv  ../tb/tx_sequence.sv  ../tb/wb_sequence.sv  ../tb/rst_sequence.sv  ../tb/tx_driver.sv  ../tb/wb_driver.sv  ../tb/rst_driver.sv  ../tb/tx_monitor.sv  ../tb/rx_monitor.sv  ../tb/wb_monitor.sv  ../tb/rst_monitor.sv  ../tb/tx_agent.sv  ../tb/rx_agent.sv  ../tb/wb_agent.sv  ../tb/rst_agent.sv  ../tb/seq_of_commands.sv  ../tb/virtual_sequencer.sv  ../tb/scoreboard.sv  ../tb/mac_env.sv  ../tb/mac_test.sv  ../tb/mac_top.sv  ../tb/mac_tb.sv  

# Simulate the design.
vsim -c mac_top
run -all
exit
