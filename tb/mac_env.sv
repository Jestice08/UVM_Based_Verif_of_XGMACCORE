//This is env module
//Designed by Xuezhi Teng

`ifndef MAC_ENV_SV
`define MAC_ENV_SV

//`include "rst_agent.sv"
//`include "wb_agent.sv"
//`include "tx_agent.sv"
//`include "rx_agent.sv"
//`include "scoreboard.sv"

`include "uvm_macros.svh"

import uvm_pkg::*;
import mac_pkg::*;


class mac_env extends uvm_env;

	rst_agent 			rst_agent_h;
	wb_agent			wb_agent_h;
	tx_agent			tx_agent_h;
	rx_agent			rx_agent_h;
	scoreboard			scoreboard_h;
	
	`uvm_component_utils(mac_env)
	
	function new(input string name, input uvm_component parent);
		super.new(name, parent);
	endfunction : new
	
	
	virtual function void build_phase (input uvm_phase phase);
		super.build_phase(phase);
		rst_agent_h   = rst_agent::type_id::create("rst_agent_h",this);
		wb_agent_h	  = wb_agent::type_id::create("wb_agent_h",this);
		tx_agent_h    = tx_agent::type_id::create("tx_agent_h",this);
		rx_agent_h    = rx_agent::type_id::create("rx_agent_h", this);
		scoreboard_h  = scoreboard::type_id::create("scoreboard_h",this);
	endfunction : build_phase
		
	virtual function void connect_phase (input uvm_phase phase);
		super.connect_phase(phase);
	    tx_agent_h.tx_agt_aport.connect(scoreboard_h.scbd_tx_agt_port);  //connecting the subscriber to the environment
        rx_agent_h.rx_agt_aport.connect(scoreboard_h.scbd_rx_agt_port);
		wb_agent_h.aport.connect(scoreboard_h.scbd_wb_agt_port);
    endfunction: connect_phase	
	
endclass : mac_env

`endif //MAC_ENV_SV
	
	
	
	
	
	
	
	
	
	
	
	
