`ifndef RST_SEQUENCE__SV
`define RST_SEQUENCE__SV

`include "uvm_macros.svh"

import uvm_pkg::*;

class rst_sequence extends uvm_sequence #(rst_transaction_in);

	`uvm_object_utils(rst_sequence)

	function new(input string name="rst_sequence");
		super.new(name);
    	`uvm_info( get_name(), $sformatf("Hierarchy: %m"), UVM_HIGH )
  	endfunction : new

  	virtual task body();
  	begin
    	//Reset stage
    	`uvm_do_with(req, { rst_156m25_n == 1'b0; rst_xgmii_rx_n == 1'b0; rst_xgmii_tx_n == 1'b0; wb_rst == 1'b1;} );
    	//End reset
    	`uvm_do_with(req, { rst_156m25_n == 1'b1; rst_xgmii_rx_n == 1'b1; rst_xgmii_tx_n == 1'b1; wb_rst == 1'b0;} );
  	end
  	endtask : body

  	virtual task pre_start();
    	if ( starting_phase != null )
      		starting_phase.raise_objection( this );
  	endtask : pre_start

  	virtual task post_start();
    	if  ( starting_phase != null )
      		starting_phase.drop_objection( this );
  	endtask : post_start

endclass: rst_sequence


`endif