`ifndef MAC_TB__SV
`define MAC_TB__SV

program mac_tb();

  import uvm_pkg::*;

  //`include "testclass.sv"
  //`include "test_lib.svh"

  initial begin
    uvm_top.run_test("basic_test");
  end

endprogram : mac_tb

`endif