`ifndef WB_AGENT__SV
`define WB_AGENT__SV


`include "wb_driver.sv"
`include "wb_monitor.sv"
typedef uvm_sequencer #(wb_transaction_in) wb_sequencer;

class wb_agent extends uvm_agent;
    `uvm_component_utils(wb_agent)
    uvm_analysis_port #(wb_transaction_in) aport;

    wb_sequencer wb_sequencer_h;
    wb_driver wb_driver_h;
    wb_monitor wb_monitor_h;

    function new( input string name="wb_agent", input uvm_component parent );
        super.new(name,parent);
  	endfunction: new

  	virtual function void build_phase(input uvm_phase phase);
        super.build_phase(phase);
        aport=new("aport",this);
        wb_sequencer_h = wb_sequencer::type_id::create("wb_sequencer_h",this);
        wb_driver_h = wb_driver::type_id::create("wb_driver_h",this);
        wb_monitor_h = wb_monitor::type_id::create("wb_sequencer_h",this);
    endfunction: build_phase 

    virtual function void connect_phase( input uvm_phase phase );
    	super.connect_phase(phase);
        wb_driver_h.seq_item_port.connect(wb_sequencer_h.seq_item_export);
        wb_monitor_h.aport.connect(aport);
    endfunction: connect_phase 

endclass: wb_agent

`endif