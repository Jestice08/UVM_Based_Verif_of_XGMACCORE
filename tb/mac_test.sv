//This is the basic test
//Designed by Xuezhi Teng


`ifndef MAC_TEST_SV
`define MAC_TEST_SV

//`include "rst_sequence.sv"
//`include "wb_sequence.sv"
//`include "tx_sequence.sv"
//`include "mac_env.sv"
//`include "virtual_sequencer.sv"
//`include "seq_of_commands.sv"
`include "uvm_macros.svh"
//`include "mac_top.sv"

import uvm_pkg::*;
import mac_pkg::*;

class mac_test extends uvm_test;
	
	`uvm_component_utils(mac_test);
	
	mac_env			mac_env_h;
	
	function new(input string name, input uvm_component parent);
		super.new(name, parent);
	endfunction : new

	virtual function void build_phase (input uvm_phase phase);
		super.build_phase(phase);
		mac_env_h = mac_env::type_id::create("mac_env_h", this);
		
		
// ==== Assign virtual interface ================================
    uvm_config_db #(virtual mac_interface)::set(this, "mac_env_h.rst_agent_h.rst_driver_h", "rst_drv_vi_if", mac_top.mac_if);
    uvm_config_db #(virtual mac_interface)::set(this, "mac_env_h.wb_agent_h.wb_monitor_h", "wb_mon_vi_if", mac_top.mac_if);
    uvm_config_db #(virtual mac_interface)::set(this, "mac_env_h.wb_agent_h.wb_driver_h", "wb_drv_vi_if", mac_top.mac_if);
    uvm_config_db #(virtual mac_interface)::set(this, "mac_env_h.tx_agent_h.tx_monitor_h", "mon_vi", mac_top.mac_if);
    uvm_config_db #(virtual mac_interface)::set(this, "mac_env_h.tx_agent_h.tx_driver_h", "drv_vi", mac_top.mac_if);
    uvm_config_db #(virtual mac_interface)::set(this, "mac_env_h.rx_agent_h.rx_monitor_h", "mon_vi", mac_top.mac_if);
   // uvm_config_db #(virtual mac_interface)::set(this, "mac_env_h.xgmii_tx_agt.xgmii_tx_mon", "mon_vi", mac_top.mac_if);
   // uvm_config_db #(virtual mac_interface)::set(this, "mac_env_h.xgmii_rx_agt.xgmii_rx_mon", "mon_vi", mac_top.mac_if);
    // ==============================================================

    // ==== Run the sequence on the sequencer using uvm_config_db ===
    uvm_config_db #(uvm_object_wrapper)::set(this, "mac_env_h.rst_agent_h.rst_sequencer_h.reset_phase", "default_sequence", rst_sequence::get_type() );
    uvm_config_db #(uvm_object_wrapper)::set(this, "mac_env_h.wb_agent_h.wb_sequencer_h.configure_phase", "default_sequence", wb_sequence_config::get_type() );
    uvm_config_db #(uvm_object_wrapper)::set(this, "mac_env_h.tx_agent_h.tx_sequencer_h.main_phase", "default_sequence", tx_sequence::get_type() );
    // ==============================================================

    // ==== Set the number of packets in the sequence ===============
    //uvm_config_db #(int unsigned)::set(this, "mac_env_h.tx_agent_h.pkt_tx_seqr.packet_sequence", "num_packets", 10 );
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


//  virtual function void report_phase(input uvm_phase phase);
//    uvm_report_server svr;
//    svr = uvm_report_server::get_server();
//    if (svr.get_severity_count(UVM_ERROR))
//      `uvm_error(get_name(), "***** UVM TEST FAILED *****")
//  endfunction : report_phase

endclass : mac_test



class virtual_sequence_test_base extends mac_test;

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
    virtual_sequencer_h.rst_sequencer_h  = mac_env_h.rst_agent_h.rst_sequencer_h;
    virtual_sequencer_h.wb_sequencer_h   = mac_env_h.wb_agent_h.wb_sequencer_h;
    virtual_sequencer_h.tx_sequencer_h   = mac_env_h.tx_agent_h.tx_sequencer_h;
  endfunction : connect_phase


//  virtual function void report_phase(input uvm_phase phase);
//    super.report_phase(phase);
//  endfunction : report_phase

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

`endif  // MAC_TEST_SV
