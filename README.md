# UVM Based Verifcication of 10 Gb Ethernet MAC Core

### Note: The Bug we found in small-size packet test is fixed now. If you want to inject it, go to dut/verilog/tx_dequeue.sv : 733, uncomment it.

**1. Select a test you want to run:**

   Go to tb/mac_test_top.sv : 109, uncomment one of the test. You can choose the basic test, small-size packet test and big-size test.
   
**2. Run the UVM test:**

   Our testbench can be ran in both Synopsys VCS and Mentor Graphics Modelsim.
   
   a. To launch Synopsys VCS: 
     
      module load syn/vcs
       
      cd sim
   
      make vcs
   
      ./simv  (if you want to look at the waveforms and debug)
   
   b. To launch Mentor Graphics Modelsim:
    
      module load mentor/modelsim/2016
    
      cd sim
    
      make modelsim  (if you want to open the gui for debug, choose make gui instead)
                                   
**3. To clean all the simulation files:**
    
    make clean
