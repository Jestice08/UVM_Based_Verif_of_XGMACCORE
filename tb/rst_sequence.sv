//*********************************************
//          UVM Based Verification of         *
//           10 Gb Ethernet MAC Core          *
//                                            *
// Team member: Xuezhi Teng (xt2276)          *
//              Yi Zheng    (yz24299)         *
//*********************************************

// This is rst_sequence file. It is used for generate the reset sequence item and reset sequence.
`include "uvm_macros.svh"
package rst_seq_pkg;
import uvm_pkg::*;

//*********Part 1: rst_seq_item****************



class rst_seq_item extends uvm_sequence_item;

	`uvm_object_utils(rst_seq_item)
	
	rand logic rst_156m25_n;
	rand logic rst_xgmii_rx_n;
	rand logic rst_xgmii_tx_n;
	rand logic wb_rst;

	function new(input string name="rst_seq_item");
		super.new();
	endfunction : new

endclass : rst_seq_item

//**********************************************


//*********Part 2: rst_sequence*****************

class rst_sequence extends uvm_sequence #(rst_seq_item);

    `uvm_object_utils(rst_sequence)

	function new(input string name="rst_sequence");
		super.new(name);
	endfunction : new


  virtual task body();
    `uvm_do_with(req, { rst_156m25_n == 1'b0; rst_xgmii_rx_n == 1'b0; rst_xgmii_tx_n == 1'b0; wb_rst == 1'b1;} );
    `uvm_do_with(req, { rst_156m25_n == 1'b1; rst_xgmii_rx_n == 1'b1; rst_xgmii_tx_n == 1'b1; wb_rst == 1'b0;} );  
  endtask : body


  virtual task pre_start();
    if ( starting_phase != null )
      starting_phase.raise_objection( this );
  endtask : pre_start


  virtual task post_start();
    if  ( starting_phase != null )
      starting_phase.drop_objection( this );
  endtask : post_start

endclass : rst_sequence

//**********************************************

endpackage : rst_seq_pkg
