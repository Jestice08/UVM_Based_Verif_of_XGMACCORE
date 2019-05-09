`ifndef VIRTUAL_SEQUENCER__SV
`define VIRTUAL_SEQUENCER__SV


`include "uvm_macros.svh"

import uvm_pkg::*;
import mac_pkg::*;

class virtual_sequencer extends uvm_sequencer;

  `uvm_component_utils(virtual_sequencer)

  rst_sequencer       	rst_sequencer_h;
  wb_sequencer    		wb_sequencer_h;
  tx_sequencer   		tx_sequencer_h;

  function new(input string name="virtual_sequencer", input uvm_component parent);
    super.new(name, parent);
  endfunction : new

endclass : virtual_sequencer

`endif