`ifndef RX_AGENT_SV
`define RX_AGENT_SV

`inculde "rx_monitor.sv"

class rx_agent extends uvm_agent;

	`uvm_component_utils (rx_agent)
	
	uvm_analysis_port #(rx_transaction) rx_agt_aport;

	rx_monitor		rx_monitor_h;
	
	function new (input string name = "rx_agent", input uvm_component parent);
		super.new (name, parent);
	endfunction : new
	
	virtual function void build_phase (input uvm_phase phase);
		//super.build_phase (phase);
		rx_agt_aport     = new ( "rx_agt_aport", this );
		rx_monitor_h     = rx_monitor::type_id::create( "rx_monitor_h", this );
	endfunction : build_phase
	
	virtual function void connect_phase (input uvm_phase phase);
        rx_monitor_h.rx_mon_aport.connect(rx_agt_aport);   //Connecting the monitor to the outside agent
    endfunction: connect_phase
	
endclass : rx_agent

`endif


	