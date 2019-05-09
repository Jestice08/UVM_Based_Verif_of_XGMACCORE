`ifndef RST_MONITOR__SV
`define RST_MONITOR__SV
//`include  "rst_seq_item.sv"

import uvm_pkg::*;
`include "uvm_macros.svh"

class rst_monitor extends uvm_monitor;
	`uvm_component_utils(rst_monitor)

	uvm_analysis_port #(rst_transaction_in) aport;
	int unsigned	m_num_captured;
	virtual mac_interface	rst_mon_vi_if;

	function new(input string name="rst_monitor", input uvm_component parent);
		super.new(name, parent);
	endfunction : new

	virtual function void build_phase(input uvm_phase phase);
		super.build_phase(phase);
		m_num_captured = 0;
		aport=new("aport",this);
		uvm_config_db#(virtual mac_interface)::get(this, "", "rst_mon_vi_if", rst_mon_vi_if);
    	if ( rst_mon_vi_if==null )
      		`uvm_fatal(get_name(), "No virtual interface for wishbone monitor.");
	endfunction: build_phase

	virtual task run_phase(input uvm_phase phase);
		rst_transaction_in mon_in_rst;
		`uvm_info( get_name(), $sformatf("HIERARCHY: %m"), UVM_HIGH);

		forever
		begin
			@(rst_mon_vi_if.mon_cb)
			begin
				//monitor the value when the transmission finished
				if (rst_mon_vi_if.mon_cb.reset_156m25_n)
				begin
					mon_in_rst = rst_transaction_in::type_id::create("mon_in_rst");
					mon_in_rst.rst_156m25_n = rst_mon_vi_if.mon_cb.reset_156m25_n;
					mon_in_rst.rst_xgmii_rx_n = rst_mon_vi_if.mon_cb.reset_xgmii_rx_n;
					mon_in_rst.rst_xgmii_tx_n = rst_mon_vi_if.mon_cb.reset_xgmii_tx_n;
					mon_in_rst.wb_rst = rst_mon_vi_if.mon_cb.wb_rst_i;
					`uvm_info( get_name(), $psprintf("Wishbone Transaction: \n%0s", mon_in_rst.sprint()), UVM_HIGH)
					aport.write(mon_in_rst);
					m_num_captured++;
				end
			end
		end
	endtask: run_phase

  	function void report_phase( uvm_phase phase );
    	`uvm_info( get_name( ), $sformatf( "REPORT: Captured %0d wishbone transactions", m_num_captured ), UVM_LOW )
  	endfunction : report_phase

endclass: rst_monitor
`endif