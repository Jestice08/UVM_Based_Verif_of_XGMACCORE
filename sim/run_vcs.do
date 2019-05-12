vcs -full64 -R -sverilog -l vcs.log -ntb_opts uvm-1.1 -debug_pp +vcs+vcdpluson +ntb_random_seed_automatic   \
-override_timescale=1ps/1ps                 \
+incdir+../dut/include/                     \
../dut/verilog/*.v                          \
+incdir+../tb/                       \
../tb/mac_interface.sv ../tb/rst_sequence.sv ../tb/wb_sequence.sv  ../tb/tx_sequence.sv ../tb/tx_driver.sv  ../tb/tx_monitor.sv  ../tb/rx_monitor.sv  ../tb/rst_modules.sv  ../tb/wb_modules.sv  ../tb/tx_agent.sv  ../tb/rx_agent.sv  ../tb/scoreboard.sv  ../tb/mac_env.sv  ../tb/virtual_sequencer.sv  ../tb/testclass.sv  ../tb/mac_test_top.sv 
