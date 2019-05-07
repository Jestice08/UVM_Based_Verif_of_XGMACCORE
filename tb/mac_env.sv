//This is env module
//Designed by Xuezhi Teng
`ifndef MAC_ENV_SV
`define MAC_ENV_SV

`include "rst_agent.sv"
`include "wb_agent.sv"
`include "tx_agent.sv"
`include "rx_agent.sv"
`include "scoreboard.sv"


class mac_env extends uvm_env;

	rst_agent 			rst_agent_h;
	wb_agent			wb_agent_h;
	tx_agent			tx_agent_h;
	rx_agent			rx_agent_h;
	scoreboard			scoreboard_h;
	
	`uvm_component_utils(env)
	
	function new(input string name, input uvm_component parent);
		super.new(name, parent);
	endfunction : new
	
	
	virtual function void build_phase (input uvm_phase phase);
		rst_agent_h   = rst_agent::type_id::creat("rst_agent_h",this);
		wb_agent_h	  = wb_agent::type_id::creat("wb_agent_h",this);
		tx_agent_h    = tx