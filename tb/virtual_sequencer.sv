//*********************************************
//          UVM Based Verification of         *
//           10 Gb Ethernet MAC Core          *
//                                            *
// Team member: Xuezhi Teng (xt2276)          *
//              Yi Zheng    (yz24299)         *
//*********************************************
`include "uvm_macros.svh"
package v_seqr_pkg; 
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

class virtual_sequencer extends uvm_sequencer;

  `uvm_component_utils(virtual_sequencer)

  rst_sequencer       rst_sequencer_vi;
  wb_sequencer        wb_sequencer_vi;
  tx_sequencer        tx_sequencer_vi;

  function new(input string name="virtual_sequencer", input uvm_component parent);
    super.new(name, parent);
  endfunction : new

endclass : virtual_sequencer
class seq_of_commands extends uvm_sequence;

  `uvm_object_utils(seq_of_commands)
  `uvm_declare_p_sequencer(virtual_sequencer)

  rst_sequence            rst_sequence_vi;
  wb_sequence_config      wb_seq_config_vi;
  wb_sequence_finish      wb_seq_finish_vi;
  tx_sequence             tx_sequence_vi;

  function new(input string name="seq_of_commands");
    super.new(name);
    `uvm_info( get_name(), $sformatf("Hierarchy: %m"), UVM_HIGH )
  endfunction : new


  virtual task body();
    `uvm_do_on( tx_sequence_vi, p_sequencer.tx_sequencer_vi );
    #1000000;
    `uvm_do_on( wb_seq_finish_vi, p_sequencer.wb_sequencer_vi );
  endtask : body


  virtual task pre_start();
    super.pre_start();
    if ( (starting_phase!=null) && (get_parent_sequence()==null) )
      starting_phase.raise_objection( this );
  endtask : pre_start


  virtual task post_start();
    super.post_start();
    if ( (starting_phase!=null) && (get_parent_sequence()==null) )
      starting_phase.drop_objection( this );
  endtask : post_start

endclass : seq_of_commands




endpackage : v_seqr_pkg
