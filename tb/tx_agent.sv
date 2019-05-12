//*********************************************
//          UVM Based Verification of         *
//           10 Gb Ethernet MAC Core          *
//                                            *
// Team member: Xuezhi Teng (xt2276)          *
//              Yi Zheng    (yz24299)         *
//*********************************************
`include "uvm_macros.svh"
package pkt_tx_agent_pkg;
import uvm_pkg::*;
import pkt_seq_pkg::*;
import pkt_tx_driver_pkg::*;
import pkt_tx_monitor_pkg::*;

typedef uvm_sequencer #(tx_transaction) tx_sequencer;


class tx_agent extends uvm_agent;

  tx_sequencer           tx_sequencer_h;
  tx_driver              tx_driver_h;
  tx_monitor             tx_monitor_h;
  uvm_analysis_port #(tx_transaction)   tx_agent_aport;

  `uvm_component_utils( tx_agent )

  function new( input string name="tx_agent", input uvm_component parent );
    super.new( name, parent );
  endfunction : new


  virtual function void build_phase( input uvm_phase phase );
    super.build_phase( phase );
    tx_sequencer_h = tx_sequencer::type_id::create( "tx_sequencer_h", this );
    tx_driver_h  = tx_driver::type_id::create( "tx_driver_h", this );
    tx_monitor_h  = tx_monitor::type_id::create( "tx_monitor_h", this );
    tx_agent_aport = new ( "tx_agent_aport", this );
  endfunction : build_phase


  virtual function void connect_phase( input uvm_phase phase );
    super.connect_phase( phase );
    tx_driver_h.seq_item_port.connect( tx_sequencer_h.seq_item_export );
    tx_monitor_h.tx_monitor_aport.connect(tx_agent_aport);
	//this.tx_agent_aport = tx_monitor_h.tx_monitor_aport;
  endfunction : connect_phase

endclass : tx_agent

endpackage : pkt_tx_agent_pkg
