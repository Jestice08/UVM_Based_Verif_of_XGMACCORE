import uvm_pkg::*;
`include "uvm_macros.svh"

`ifndef rst_AGENT__SV
`define rst_AGENT__SV
//import uvm_pkg::*;

`include "rst_driver.sv"
`include "rst_monitor.sv"
typedef uvm_sequencer #(rst_transaction_in) rst_sequencer;

class rst_agent extends uvm_agent;
    `uvm_component_utils(rst_agent)
    uvm_analysis_port #(rst_transaction_in) aport;

    rst_sequencer rst_sequencer_h;
    rst_driver rst_driver_h;
    rst_monitor rst_monitor_h;

    function new( input string name="rst_agent", input uvm_component parent );
        super.new(name,parent);
  	endfunction: new

  	virtual function void build_phase(input uvm_phase phase);
        super.build_phase(phase);
        aport=new("aport",this);
        rst_sequencer_h = rst_sequencer::type_id::create("rst_sequencer_h",this);
        rst_driver_h = rst_driver::type_id::create("rst_driver_h",this);
        rst_monitor_h = rst_monitor::type_id::create("rst_sequencer_h",this);
    endfunction: build_phase 

    virtual function void connect_phase( input uvm_phase phase );
        super.connect_phase(phase);
        rst_driver_h.seq_item_port.connect(rst_sequencer_h.seq_item_export);
        rst_monitor_h.aport.connect(aport);
    endfunction: connect_phase 

endclass: rst_agent

`endif