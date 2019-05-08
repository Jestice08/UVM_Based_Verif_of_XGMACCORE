//This is tx_agent
//Designed by Xuezhi Teng
`ifndef TX_AGENT_SV
`define TX_AGENT_SV

`include "tx_driver.sv"
`inculde "tx_monitor.sv"

typedef uvm_sequencer #(tx_transaction) tx_sequencer;

class tx_agent extends uvm_agent;

	`uvm_component_utils (tx_agent)
	
	uvm_analysis_port #(tx_transaction) tx_agt_aport;
	
	tx_sequencer	tx_sequencer_h;  //h means handle
	tx_driver 		tx_driver_h;
	tx_monitor		tx_monitor_h;
	
	function new (input string name = "tx_agent", input uvm_component parent);
		super.new (name, parent);
	endfunction : new
	
	virtual function void build_phase (input uvm_phase phase);
		super.build_phase(phase);
		tx_agt_aport     = new ( "tx_agt_aport", this );
		tx_sequencer_h   = tx_sequencer::type_id::create( "tx_sequencer_h", this );
		tx_driver_h      = tx_driver::type_id::create( "tx_driver_h", this );
		tx_monitor_h     = tx_monitor::type_id::create( "tx_monitor_h", this );
	endfunction : build_phase
	
	virtual function void connect_phase (input uvm_phase phase);
	    super.connect_phase(phase);
		tx_driver_h.seq_item_port.connect( tx_sequencer_h.seq_item_export );
        tx_monitor_h.tx_mon_aport.connect(tx_agt_aport);   //Connecting the monitor to the outside agent
    endfunction: connect_phase
	
endclass : tx_agent

`endif //TX_AGENT_SV


	