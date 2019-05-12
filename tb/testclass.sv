//*********************************************
//          UVM Based Verification of         *
//           10 Gb Ethernet MAC Core          *
//                                            *
// Team member: Xuezhi Teng (xt2276)          *
//              Yi Zheng    (yz24299)         *
//*********************************************
`include "uvm_macros.svh"
package multi_test_pkg; 

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
import test_env_pkg::*;
import v_seqr_pkg::*;


class test_base extends uvm_test;

  mac_env               mac_env_h;
  virtual mac_interface     mac_if_0;

  `uvm_component_utils( test_base );

  function new(input string name, input uvm_component parent);
    super.new(name, parent);
  endfunction : new


  virtual function void build_phase(input uvm_phase phase);
    super.build_phase(phase);
    mac_env_h = mac_env::type_id::create("mac_env_h", this);

    // ==== Connect DUT via config macros ===========================
    uvm_config_db #(virtual mac_interface)::get(null, "uvm_test_top", "dut_config", mac_if_0);

    // ==== Assign virtual interface ================================
    uvm_config_db #(virtual mac_interface)::set(this, "mac_env_h.rst_agent_h.rst_driver_h", "drv_vi", mac_if_0);
    uvm_config_db #(virtual mac_interface)::set(this, "mac_env_h.wb_agent_h.wb_monitor_h", "mon_vi", mac_if_0);
    uvm_config_db #(virtual mac_interface)::set(this, "mac_env_h.wb_agent_h.wb_driver_h", "drv_vi", mac_if_0);
    uvm_config_db #(virtual mac_interface)::set(this, "mac_env_h.tx_agent_h.tx_monitor_h", "mon_vi", mac_if_0);
    uvm_config_db #(virtual mac_interface)::set(this, "mac_env_h.tx_agent_h.tx_driver_h", "drv_vi", mac_if_0);
    uvm_config_db #(virtual mac_interface)::set(this, "mac_env_h.rx_agent_h.rx_monitor_h", "mon_vi", mac_if_0);
    // ==============================================================

    // ==== Run the sequence on the sequencer using uvm_config_db ===
    uvm_config_db #(uvm_object_wrapper)::set(this, "mac_env_h.rst_agent_h.rst_sequencer_h.reset_phase", "default_sequence", rst_sequence::get_type() );
    uvm_config_db #(uvm_object_wrapper)::set(this, "mac_env_h.wb_agent_h.wb_sequencer_h.configure_phase", "default_sequence", wb_sequence_config::get_type() );
    uvm_config_db #(uvm_object_wrapper)::set(this, "mac_env_h.tx_agent_h.tx_sequencer_h.main_phase", "default_sequence", tx_sequence::get_type() );
    // ==============================================================

    // ==== Set the number of packets in the sequence ===============
    uvm_config_db #(int unsigned)::set(this, "mac_env_h.tx_agent_h.tx_sequencer_h.tx_sequence", "num_packets", 10 );
    // ==============================================================
  endfunction : build_phase


  virtual function void end_of_elaboration_phase(input uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    `uvm_info(get_name(), "Printing Topology from end_of_elaboration phase", UVM_MEDIUM)
    if ( uvm_report_enabled(UVM_MEDIUM) ) begin
      uvm_top.print_topology();
    end
  endfunction : end_of_elaboration_phase


  virtual function void start_of_simulation_phase(input uvm_phase phase);
    super.start_of_simulation_phase(phase);
    `uvm_info(get_name(), "Printing factory from start_of_simulation phase", UVM_MEDIUM);
    if ( uvm_report_enabled(UVM_MEDIUM) ) begin
      factory.print();
    end
  endfunction  : start_of_simulation_phase


  virtual task run_phase(input uvm_phase phase);
    `uvm_info(get_name(), $sformatf("%m"), UVM_HIGH);
  endtask : run_phase


  virtual task main_phase( input uvm_phase phase);
    uvm_objection   objection;
    super.main_phase(phase);
    objection = phase.get_objection();
    objection.set_drain_time(this, 1us);
  endtask : main_phase


endclass : test_base



class virtual_sequence_test_base extends test_base;

  virtual_sequencer     virtual_sequencer_h;

  `uvm_component_utils( virtual_sequence_test_base );

  function new(input string name, input uvm_component parent);
    super.new(name, parent);
  endfunction : new


  virtual function void build_phase(input uvm_phase phase);
    super.build_phase(phase);
    virtual_sequencer_h = virtual_sequencer::type_id::create("virtual_sequencer_h", this);

    // Reset and Configure sequences remain untouched ===============
    uvm_config_db #(uvm_object_wrapper)::set(this, "mac_env_h.rst_agent_h.rst_sequencer_h.reset_phase", "default_sequence", rst_sequence::get_type());
    uvm_config_db #(uvm_object_wrapper)::set(this, "mac_env_h.wb_agent_h.wb_sequencer_h.configure_phase", "default_sequence", wb_sequence_config::get_type());
    uvm_config_db #(uvm_object_wrapper)::set(this, "mac_env_h.tx_agent_h.tx_sequencer_h.main_phase", "default_sequence", null);
    // ==============================================================

    // Run the virtual_sequence on the virtual_sequencer ============
    uvm_config_db #(uvm_object_wrapper)::set(this, "virtual_sequencer_h.main_phase", "default_sequence", seq_of_commands::get_type() );
    // ==============================================================
  endfunction : build_phase


  virtual function void connect_phase(input uvm_phase phase);
    super.connect_phase(phase);
    virtual_sequencer_h.rst_sequencer_vi     = mac_env_h.rst_agent_h.rst_sequencer_h;
    virtual_sequencer_h.wb_sequencer_vi      = mac_env_h.wb_agent_h.wb_sequencer_h;
    virtual_sequencer_h.tx_sequencer_vi      = mac_env_h.tx_agent_h.tx_sequencer_h;
  endfunction : connect_phase

endclass : virtual_sequence_test_base

class basic_test extends virtual_sequence_test_base;

  `uvm_component_utils( basic_test )

  function new(input string name, input uvm_component parent);
    super.new(name, parent);
  endfunction : new


  virtual function void build_phase(input uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_name(), $sformatf("Hierarchy: %m"), UVM_NONE )
    factory.set_type_override_by_type(  tx_transaction::get_type() ,
                                        tx_transaction_basic::get_type() );
  endfunction : build_phase

endclass : basic_test

class small_size_test extends virtual_sequence_test_base;

  `uvm_component_utils( small_size_test )

  function new(input string name, input uvm_component parent);
    super.new(name, parent);
  endfunction : new


  virtual function void build_phase(input uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_name(), $sformatf("Hierarchy: %m"), UVM_NONE )
    factory.set_type_override_by_type(  tx_transaction::get_type() ,
                                        tx_transaction_smallsize::get_type() );
  endfunction : build_phase

endclass : small_size_test

class big_size_test extends virtual_sequence_test_base;

  `uvm_component_utils( big_size_test )

  function new(input string name, input uvm_component parent);
    super.new(name, parent);
  endfunction : new


  virtual function void build_phase(input uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_name(), $sformatf("Hierarchy: %m"), UVM_NONE )
    factory.set_type_override_by_type(  tx_transaction::get_type() ,
                                        tx_transaction_bigsize::get_type() );
  endfunction : build_phase

endclass : big_size_test

endpackage : multi_test_pkg
