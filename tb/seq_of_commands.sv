`ifndef SEQ_OF_COMMANDS__SV
`define SEQ_OF_COMMANDS__SV
`include "uvm_macros.svh"

import uvm_pkg::*;
import mac_pkg::*;

class seq_of_commands extends uvm_sequence;

	`uvm_object_utils(seq_of_commands)
	`uvm_declare_p_sequencer(virtual_sequencer)

	rst_sequence            rst_sequence_h;
	wb_sequence_config    	wb_sequence_config_h;
	wb_sequence_finish     	wb_sequence_finish_h;
	tx_sequence           	tx_sequence_h;

	function new(input string name="seq_of_commands");
    	super.new(name);
    	`uvm_info( get_name(), $sformatf("Hierarchy: %m"), UVM_HIGH )
  	endfunction : new

  	virtual task body();
    	`uvm_do_on( tx_sequence_h, p_sequencer.tx_sequencer_h );
    	#100;
    	`uvm_do_on( wb_sequence_finish_h, p_sequencer.wb_sequencer_h );
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
`endif
