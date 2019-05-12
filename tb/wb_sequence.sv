//*********************************************
//          UVM Based Verification of         *
//           10 Gb Ethernet MAC Core          *
//                                            *
// Team member: Xuezhi Teng (xt2276)          *
//              Yi Zheng    (yz24299)         *
//*********************************************

//This is wishbone sequence file. It is used for generating wishbone sequence item and wishbone sequence.
`include "define.sv"
`include "uvm_macros.svh"
package wb_seq_pkg;
import uvm_pkg::*;


//***************Part 1: Wishbone sequence item*****************
class wb_seq_item extends uvm_sequence_item;

  `uvm_object_utils(wb_seq_item);

	rand bit [7:0] wb_addr;
	rand bit [31:0] wb_data;
	rand bit wb_cyc, wb_stb, wb_we;
	
	
  constraint wb_addr_cstnt {
    wb_addr == `CPUREG_CONFIG0 ||   // Configuration register 0   : Address 0x00
    wb_addr == `CPUREG_INT_PENDING ||   // Interrupt Pending Register : Address 0x08
    wb_addr == `CPUREG_INT_STATUS ||   // Interrupt Status Register  : Address 0x0C
    wb_addr == `CPUREG_INT_MASK;     // Interrupt Mask Register    : Address 0x010
  }

  function new(input string name="wb_seq_item");
    super.new();
  endfunction : new
  
  function string convert2string;
        convert2string={$sformatf("Address = %b, Data = %b, Cyc = %b, Stb = %b, We = %b", wb_addr, wb_data, wb_cyc, wb_stb, wb_we)};
  endfunction: convert2string

endclass : wb_seq_item
//**************************************************************

//****************Part 2: Wishbone Config Sequence**************
class wb_sequence_config extends uvm_sequence #(wb_seq_item);

  `uvm_object_utils(wb_sequence_config)

  function new(input string name="wb_sequence_config");
    super.new(name);
  endfunction : new

  virtual task body();
		//Trigger the transmission of frames
    	`uvm_do_with(req, { wb_we == 1'b1; wb_addr == 8'h00; wb_data == 32'h00000001; wb_stb == 1'b1; wb_cyc == 1'b1;} );
    	//Enable the interrupt
    	`uvm_do_with(req, { wb_we == 1'b1; wb_addr == 8'h10; wb_data == 32'hFFFFFFFF; wb_stb == 1'b1; wb_cyc == 1'b1;} );  
  endtask : body


  virtual task pre_start();
    if ( starting_phase != null )
      starting_phase.raise_objection( this );
  endtask : pre_start


  virtual task post_start();
    if  ( starting_phase != null )
      starting_phase.drop_objection( this );
  endtask : post_start

endclass : wb_sequence_config
//**************************************************************


//****************Part 3: Wishbone Finish Sequence**************
class wb_sequence_finish extends uvm_sequence #(wb_seq_item);

  `uvm_object_utils(wb_sequence_finish)

  function new(input string name="wb_sequence_finish");
    super.new(name);
  endfunction : new


  virtual task body();
	
	`uvm_do_with(req, { wb_we == 1'b0; wb_addr == 8'h00; wb_stb == 1'b1; wb_cyc == 1'b1;} );
    `uvm_do_with(req, { wb_we == 1'b0; wb_addr == 8'h08; wb_stb == 1'b1; wb_cyc == 1'b1;} );
    `uvm_do_with(req, { wb_we == 1'b0; wb_addr == 8'h0C; wb_stb == 1'b1; wb_cyc == 1'b1;} );
    `uvm_do_with(req, { wb_we == 1'b0; wb_addr == 8'h10; wb_stb == 1'b1; wb_cyc == 1'b1;} );
  endtask : body


  virtual task pre_start();
    if ( starting_phase != null )
      starting_phase.raise_objection( this );
  endtask : pre_start


  virtual task post_start();
    if  ( starting_phase != null )
      starting_phase.drop_objection( this );
  endtask : post_start

endclass : wb_sequence_finish

endpackage : wb_seq_pkg