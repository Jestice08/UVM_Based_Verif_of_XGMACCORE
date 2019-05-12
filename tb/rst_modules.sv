//*********************************************
//          UVM Based Verification of         *
//           10 Gb Ethernet MAC Core          *
//                                            *
// Team member: Xuezhi Teng (xt2276)          *
//              Yi Zheng    (yz24299)         *
//*********************************************

//This is rst_modules file, it contains the all the components for reset agent, including reset driver, reset sequencer, and reset agent itself.
`include "uvm_macros.svh"
package rst_modules_pkg;
import uvm_pkg::*;
import rst_seq_pkg::*;

//****************Part 1: Reset Sequencer*******************

typedef uvm_sequencer #(rst_seq_item) rst_sequencer;

//**********************************************************


//****************Part 2: Reset Driver**********************
class rst_driver extends uvm_driver #(rst_seq_item);

  `uvm_component_utils(rst_driver)
  
  virtual mac_interface     drv_vi;

  function new(input string name="rst_driver", input uvm_component parent);
    super.new(name, parent);
  endfunction : new


  virtual function void build_phase(input uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(virtual mac_interface)::get(this, "", "drv_vi", drv_vi);
  endfunction : build_phase


  virtual task run_phase(input uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(req);
      `uvm_info( get_name(), $psprintf("Reset Transaction: \n%0s", req.sprint()), UVM_HIGH)
      
	  @(drv_vi.drv_cb);
      drv_vi.reset_156m25_n   <= req.rst_156m25_n;
      drv_vi.reset_xgmii_rx_n <= req.rst_xgmii_rx_n;
      drv_vi.reset_xgmii_tx_n <= req.rst_xgmii_tx_n;
      drv_vi.wb_rst_i         <= req.wb_rst;
      
	  repeat (5)
        
	  @(drv_vi.drv_cb);
      seq_item_port.item_done();
    end
  endtask : run_phase

endclass : rst_driver
//*********************************************************

//****************Part 3: Reset Agent**********************

class rst_agent extends uvm_agent;
		
	`uvm_component_utils( rst_agent )
	
     rst_sequencer       rst_sequencer_h;
     rst_driver          rst_driver_h;

  

  function new( input string name="rst_agent", input uvm_component parent );
    super.new( name, parent );
  endfunction : new


  virtual function void build_phase( input uvm_phase phase );
    super.build_phase( phase );
    rst_sequencer_h    = rst_sequencer::type_id::create( "rst_sequencer_h", this );
    rst_driver_h     = rst_driver::type_id::create( "rst_driver_h", this );
  endfunction : build_phase


  virtual function void connect_phase( input uvm_phase phase );
    super.connect_phase( phase );
    rst_driver_h.seq_item_port.connect( rst_sequencer_h.seq_item_export );
  endfunction : connect_phase

endclass : rst_agent

//**********************************************************
endpackage : rst_modules_pkg