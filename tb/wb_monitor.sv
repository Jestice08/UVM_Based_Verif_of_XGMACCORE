`ifndef WB_MONITOR__SV
`define WB_MONITOR__SV

`include "uvm_macros.svh"

import uvm_pkg::*;
import mac_pkg::*;


class wb_monitor extends uvm_monitor;
	`uvm_component_utils(wb_monitor)

	uvm_analysis_port #(wb_transaction_in) aport;
	int unsigned	m_num_captured;
	virtual mac_interface	wb_mon_vi_if;

	function new(input string name="wb_monitor", input uvm_component parent);
		super.new(name, parent);
	endfunction : new

	virtual function void build_phase(input uvm_phase phase);
		super.build_phase(phase);
		m_num_captured = 0;
		aport=new("aport",this);
		uvm_config_db#(virtual mac_interface)::get(this, "", "wb_mon_vi_if", wb_mon_vi_if);
    	if ( wb_mon_vi_if==null )
      		`uvm_fatal(get_name(), "No virtual interface for wishbone monitor.");
	endfunction: build_phase

	virtual task run_phase(input uvm_phase phase);
		wb_transaction_in mon_in_wb;
		`uvm_info( get_name(), $sformatf("HIERARCHY: %m"), UVM_HIGH);

		forever
		begin
			@(wb_mon_vi_if.mon_cb)
			begin
				//monitor the value when the transmission finished
				if (wb_mon_vi_if.mon_cb.wb_ack_o && wb_mon_vi_if.mon_cb.wb_cyc_i && wb_mon_vi_if.mon_cb.wb_stb_i)
				begin
					mon_in_wb = wb_transaction_in::type_id::create("mon_in_wb");
					mon_in_wb.wb_addr = wb_mon_vi_if.mon_cb.wb_adr_i;
					mon_in_wb.wb_data = wb_mon_vi_if.mon_cb.wb_dat_i;
					mon_in_wb.wb_we = wb_mon_vi_if.mon_cb.wb_we_i;
					`uvm_info( get_name(), $psprintf("Wishbone Transaction: \n%0s", mon_in_wb.sprint()), UVM_HIGH)
					aport.write(mon_in_wb);
					m_num_captured++;
				end
			end
		end
	endtask: run_phase

  	function void report_phase( uvm_phase phase );
    	`uvm_info( get_name( ), $sformatf( "REPORT: Captured %0d wishbone transactions", m_num_captured ), UVM_LOW )
  	endfunction : report_phase

endclass: wb_monitor
`endif