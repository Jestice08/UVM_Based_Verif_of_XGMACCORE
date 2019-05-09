vcs -full64 -R -sverilog -l vcs.log -ntb_opts uvm-1.1 -debug_pp +vcs+vcdpluson +ntb_random_seed_automatic   \
-override_timescale=1ps/1ps                 \
+incdir+../dut/include/                     \
../dut/verilog/*.v                          \
+incdir+../tb/                       \
../tb/mac_tb.sv                    \
../tb/mac_top.sv                \
../tb/mac_interface.sv           \
+UVM_VERBOSITY=HIGH
