//*********************************************
//          UVM Based Verification of         *
//           10 Gb Ethernet MAC Core          *
//                                            *
// Team member: Xuezhi Teng (xt2276)          *
//              Yi Zheng    (yz24299)         *
//*********************************************

//This is tx_sequence file. It contains tx_transaction, which is sequence item and tx sequence.

`include "uvm_macros.svh"
package pkt_seq_pkg;
import uvm_pkg::*;

class tx_transaction extends uvm_sequence_item;
	
	`uvm_object_utils(tx_transaction)
	
	
	//External Signals:
	rand bit [47:0]		dst_addr;
	rand bit [47:0]		src_addr;
	rand bit [15:0]		ethernet_type;
	rand bit [7:0]		payload [];    //This is a array with unknow size
	rand bit [31:0]		inter_gap;
	
	//Internal Signals:
	rand bit set_sop;
	rand bit set_eop;
	
	
	constraint set_sop_and_eop {
	
		set_sop == 1;
		set_eop == 1;
		
	}
		
	constraint payload_size {
	
		payload.size() inside { [46:1500] };
		
	}
	
	constraint inter_gap_length {
	
		inter_gap inside { [10:50] };
	
	}
	
	function new (input string name = "tx_transaction");
		super.new(name);
	endfunction : new
	
endclass : tx_transaction


//basic transaction: make sure everything is correct
class tx_transaction_basic extends tx_transaction;

  `uvm_object_utils( tx_transaction_basic )

  constraint C_bringup 
    {
      dst_addr      == 48'hAAAA_AAAA_AAAA;
      src_addr      == 48'h5555_5555_5555;
      ethernet_type     dist { 16'h0800:=34, 16'h0806:=33, 16'h88DD:=33 };  // IPv4, ARP, IPv6
      payload.size()    inside {[45:54]};
      foreach( payload[j] )
        {
          payload[j]  == j+1;
        }
      inter_gap             == 10;
  }

  function new(input string name="tx_transaction_basic");
    super.new(name);
  endfunction : new

endclass : tx_transaction_basic


//The payload size is very big:
class tx_transaction_bigsize extends tx_transaction;

  `uvm_object_utils( tx_transaction_bigsize )

  constraint payload_size
    {
      payload.size() inside {[1501:9000]};
    }

  function new(input string name="tx_transaction_bigsize");
    super.new(name);
  endfunction : new

endclass : tx_transaction_bigsize


//The payload size is very small:
class tx_transaction_smallsize extends tx_transaction;

  `uvm_object_utils( tx_transaction_smallsize )

  constraint payload_size
    {
      payload.size() inside {[1:45]};
    }

  function new(input string name="tx_transaction_smallsize");
    super.new(name);
  endfunction : new

endclass : tx_transaction_smallsize


//TX SEQUENCE starts here:
class tx_sequence extends uvm_sequence # (tx_transaction);
		
	`uvm_object_utils(tx_sequence)
	
	function new (input string name = "tx_sequence");
		super.new(name);
	endfunction : new
	
	virtual task body ();
		repeat (100)     //Here, we are sending 100 packet, for example
		begin
		`uvm_do(req);
		end
	endtask : body
	
	virtual task pre_start ();
		if ( starting_phase != null )
		starting_phase.raise_objection(this);
	endtask : pre_start
	
	virtual task post_start ();
		if ( starting_phase != null )
		starting_phase.drop_objection(this);
	endtask : post_start
	
endclass : tx_sequence

endpackage : pkt_seq_pkg
