`ifndef MAC_TEST__SV
`define MAC_TEST__SV

program mac_test();

  import uvm_pkg::*;

  //`include "testclass.sv"
  //`include "test_lib.svh"

  initial begin
    uvm_top.run_test("basic_test");
  end

endprogram : mac_test

`endif