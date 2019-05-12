//*********************************************
//          UVM Based Verification of         *
//           10 Gb Ethernet MAC Core          *
//                                            *
// Team member: Xuezhi Teng (xt2276)          *
//              Yi Zheng    (yz24299)         *
//*********************************************

//This is wb_modules file, it contains the all the components for wishbone agent, including wishbone driver, wishbone sequencer, wishbone monitor and wishbone agent itself.
`include "uvm_macros.svh"
package wb_modules_pkg;
import uvm_pkg::*;
import wb_seq_pkg::*;

//**********************Part 1: Wishbone Sequencer***********************

typedef uvm_sequencer #(wb_seq_item) wb_sequencer;

//***********************************************************************

//**********************Part 2: Wishbone Driver**************************

class wb_driver extends uvm_driver #(wb_seq_item);

  `uvm_component_utils(wb_driver)
  
  virtual mac_interface     drv_vi;

  function new(input string name="wb_driver", input uvm_component parent);
    super.new(name, parent);
  endfunction : new

  //configure the virtual interface
  virtual function void build_phase(input uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(virtual mac_interface)::get(this, "", "drv_vi", drv_vi);
  endfunction : build_phase

  //configure run phase for wishbone driver
  //consuming sequence item if there is one
  //drive ramdom value to the wishbone interface if there is no available sequence item
  virtual task run_phase(input uvm_phase phase);
    forever begin
      seq_item_port.try_next_item(req);
      if ( req == null ) begin
        // Send random idle
        @(drv_vi.drv_cb);
        drv_vi.drv_cb.wb_cyc_i  <= 1'b0;
        drv_vi.drv_cb.wb_stb_i  <= 1'b0;
      end
      else begin
        `uvm_info( get_name(), $psprintf("Wishbone Transaction: \n%0s", req.sprint()), UVM_HIGH)
        //trigger the transmission
		@(drv_vi.drv_cb);
        drv_vi.drv_cb.wb_adr_i  <= req.wb_addr;
		drv_vi.drv_cb.wb_cyc_i  <= req.wb_cyc;
        drv_vi.drv_cb.wb_stb_i  <= req.wb_stb;
        drv_vi.drv_cb.wb_dat_i  <= req.wb_data;
        drv_vi.drv_cb.wb_we_i   <= req.wb_we;
		//hold the transmission
        repeat (2)
          @(drv_vi.drv_cb);
		  //stop the transmission
        repeat (20) begin
          drv_vi.drv_cb.wb_cyc_i  <= 1'b0;
          drv_vi.drv_cb.wb_stb_i  <= 1'b0;
          @(drv_vi.drv_cb);
        end
		//handshaking with sequencer
        seq_item_port.item_done();
      end
    end
  endtask : run_phase

endclass : wb_driver
//*****************************************************************

//**********************Part 3: Wishbone Monitor*******************

class wb_monitor extends uvm_monitor;

  `uvm_component_utils( wb_monitor )
  
  virtual mac_interface             mon_vi;
  
  uvm_analysis_port #(wb_seq_item)      ap_mon;
 
  function new(input string name="wb_monitor", input uvm_component parent);
    super.new(name, parent);
  endfunction : new


  virtual function void build_phase(input uvm_phase phase);
    super.build_phase(phase);
    ap_mon = new ( "ap_mon", this );
    uvm_config_db#(virtual mac_interface)::get(this, "", "mon_vi", mon_vi);
  endfunction : build_phase


  virtual task run_phase(input uvm_phase phase);
    wb_seq_item   mon_in_wb;
    forever begin
      @(mon_vi.mon_cb)
      begin
        if ( mon_vi.mon_cb.wb_ack_o && mon_vi.mon_cb.wb_cyc_i && mon_vi.mon_cb.wb_stb_i ) begin
          mon_in_wb = wb_seq_item::type_id::create("mon_in_wb", this);
          mon_in_wb.wb_addr = mon_vi.mon_cb.wb_adr_i;
          mon_in_wb.wb_data = mon_vi.mon_cb.wb_dat_o;
          mon_in_wb.wb_we    = mon_vi.mon_cb.wb_we_i;
          `uvm_info( get_name(), $psprintf("Wishbone Transaction: \n%0s", mon_in_wb.sprint()), UVM_HIGH)
          ap_mon.write( mon_in_wb );
        end
      end
    end
  endtask : run_phase

endclass : wb_monitor
//*************************************************************************

//***********************Part 4: Wishbone Agent****************************
class wb_agent extends uvm_agent;


  `uvm_component_utils( wb_agent )
  
  wb_sequencer                    wb_sequencer_h;
  wb_driver                       wb_driver_h;
  wb_monitor                      wb_monitor_h;
  
  uvm_analysis_port #(wb_seq_item)    wb_agent_aport;

  

  function new( input string name="wb_agent", input uvm_component parent );
    super.new( name, parent );
  endfunction : new


  virtual function void build_phase( input uvm_phase phase );
    super.build_phase( phase );
    wb_sequencer_h  = wb_sequencer::type_id::create( "wb_sequencer_h", this );
    wb_driver_h   = wb_driver::type_id::create( "wb_driver_h", this );
    wb_monitor_h   = wb_monitor::type_id::create( "wb_monitor_h", this );
    wb_agent_aport    = new ( "wb_agent_aport", this );
  endfunction : build_phase


  virtual function void connect_phase( input uvm_phase phase );
    super.connect_phase( phase );
    wb_driver_h.seq_item_port.connect( wb_sequencer_h.seq_item_export );
	wb_monitor_h.ap_mon.connect(wb_agent_aport);
  endfunction : connect_phase

endclass : wb_agent

endpackage : wb_modules_pkg
