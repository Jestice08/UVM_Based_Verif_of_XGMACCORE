//*********************************************
//          UVM Based Verification of         *
//           10 Gb Ethernet MAC Core          *
//                                            *
// Team member: Xuezhi Teng (xt2276)          *
//              Yi Zheng    (yz24299)         *
//*********************************************
`include "uvm_macros.svh"
package test_env_pkg; 
import uvm_pkg::*;
import rst_seq_pkg::*;
import rst_modules_pkg::*;
import wb_seq_pkg::*;
import wb_modules_pkg::*;
import pkt_seq_pkg::*;
import pkt_tx_driver_pkg::*;
import pkt_tx_monitor_pkg::*;
import pkt_tx_agent_pkg::*;
import pkt_rx_monitor_pkg::*;
import pkt_rx_agent_pkg::*;
import scoreboard_pkg::*;


class mac_env extends uvm_env;

  rst_agent         rst_agent_h;
  wb_agent          wb_agent_h;
  tx_agent          tx_agent_h;
  rx_agent          rx_agent_h;
  scoreboard        scbd;

  `uvm_component_utils(mac_env)

  function new(input string name, input uvm_component parent);
    super.new(name, parent);
  endfunction : new


  virtual function void build_phase( input uvm_phase phase );
    super.build_phase( phase );
    rst_agent_h    = rst_agent::type_id::create( "rst_agent_h", this );
    wb_agent_h     = wb_agent::type_id::create( "wb_agent_h", this );
    tx_agent_h     = tx_agent::type_id::create( "tx_agent_h", this );
    rx_agent_h     = rx_agent::type_id::create( "rx_agent_h", this );
    scbd           = scoreboard::type_id::create( "scbd", this );
  endfunction : build_phase


  virtual function void connect_phase ( input uvm_phase phase );
    super.connect_phase( phase );
    tx_agent_h.tx_agent_aport.connect( scbd.from_pkt_tx_agent );
    rx_agent_h.rx_agent_aport.connect( scbd.from_pkt_rx_agent );
    wb_agent_h.wb_agent_aport.connect( scbd.from_wshbn_agent );
  endfunction : connect_phase

endclass : mac_env

endpackage : test_env_pkg
