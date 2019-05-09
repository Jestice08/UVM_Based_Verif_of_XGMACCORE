`ifndef VIRTUAL_SEQUENCER__SV
`define VIRTUAL_SEQUENCER__SV

class virtual_sequencer extends uvm_sequencer;

  `uvm_component_utils(virtual_sequencer)

  rst_sequencer       	rst_sequencer_vi;
  wb_sequencer    		wb_sequencer_vi;
  tx_sequencer   		tx_sequencer_vi;

  function new(input string name="virtual_sequencer", input uvm_component parent);
    super.new(name, parent);
  endfunction : new

endclass : virtual_sequencer

`endif