//*********************************************
//          UVM Based Verification of         *
//           10 Gb Ethernet MAC Core          *
//                                            *
// Team member: Xuezhi Teng (xt2276)          *
//              Yi Zheng    (yz24299)         *
//*********************************************
`include "uvm_macros.svh"
package pkt_rx_agent_pkg;
import uvm_pkg::*;
import pkt_seq_pkg::*;
import pkt_rx_monitor_pkg::*;


class rx_agent extends uvm_agent;

  rx_monitor             rx_monitor_h;
  uvm_analysis_port #(tx_transaction)   rx_agent_aport;

  `uvm_component_utils( rx_agent )

  function new( input string name="rx_agent", input uvm_component parent );
    super.new( name, parent );
  endfunction : new


  virtual function void build_phase( input uvm_phase phase );
    super.build_phase( phase );
    rx_monitor_h  = rx_monitor::type_id::create( "rx_monitor_h", this );    
    rx_agent_aport = new ( "rx_agent_aport", this );
  endfunction : build_phase


  virtual function void connect_phase( input uvm_phase phase );
    super.connect_phase( phase );
    this.rx_agent_aport = rx_monitor_h.rx_monitor_aport;
  endfunction : connect_phase

endclass : rx_agent

endpackage : pkt_rx_agent_pkg
