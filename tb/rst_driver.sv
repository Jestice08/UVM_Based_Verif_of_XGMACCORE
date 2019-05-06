`ifndef RST_DRIVER__SV
`define RST_DRIVER__SV

class rst_driver extends uvm_driver #(rst_transaction_in);

	`uvm_component_utils(rst_driver)

	virtual mac_interface rst_vi_if;

  	function new(input string name="rst_driver", input uvm_component parent);
    	super.new(name, parent);
  	endfunction : new 

  	//configure the virtual interface
  	virtual function void build_phase(input uvm_phase phase);
    	super.build_phase(phase);
   		uvm_config_db#(virtual mac_interface)::get(this, "", "rst_vi_if", rst_vi_if);
    	if ( rst_vi_if==null )
      		`uvm_fatal(get_name(), "No virtual interface for reset driver.");
  	endfunction : build_phase
    //TODO
  	virtual task run_phase(input uvm_phase phase);
  	 forever begin
  		  seq_item_port.get_next_item(req);//blocking varient
        @(rst_vi_if.drv_cb);
          rst_vi_if.drv_cb.reset_156m25_n <= req.rst_156m25_n;
          rst_vi_if.drv_cb.reset_xgmii_rx_n <= req.rst_xgmii_rx_n;
  		    rst_vi_if.drv_cb.reset_xgmii_tx_n <= req.rst_xgmii_tx_n;
          rst_vi_if.drv_cb.wb_rst_i <= req.wb_rst;
        repeat(5) @(rst_vi_if.drv_cb);
        seq_item_port.item_done();
      end
  	endtask: run_phase 

endclass: rst_driver
`endif