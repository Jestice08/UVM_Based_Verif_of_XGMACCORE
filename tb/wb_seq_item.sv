`ifndef WB_SEQ_ITEM__SV
`define WB_SEQ_ITEM__SV

`include "uvm_macros.svh"
`include "define.v"
package sequences;

import uvm_pkg::*;

class wb_transaction_in extends uvm_sequence_item;

`uvm_object_utils(wb_transaction_in);
	rand logic [7:0] wb_addr;
	rand logic [31:0] wb_data;
	rand logic wb_cyc, wb_stb, wb_we;

	//constraints for wishbone related registers
	constraint wb_addr_cstnt 
	{
	    wb_addr == `CPUREG_CONFIG0 ||   	// Configuration register 0   : Address 0x00
	    wb_addr == `CPUREG_INT_PENDING ||   // Interrupt Pending Register : Address 0x08
	    wb_addr == `CPUREG_INT_STATUS ||   	// Interrupt Status Register  : Address 0x0C
	    wb_addr == `CPUREG_INT_MASK;     	// Interrupt Mask Register    : Address 0x010
	}

    function new(input string name = "wb_seq_item");
        super.new(name);
    endfunction: new

    function string convert2string;
        convert2string={$sformatf("Address = %b, Data = %b, Cyc = %b, Stb = %b, We = %b", wb_addr, wb_data, wb_cyc, wb_stb, wb_we)};
    endfunction: convert2string
endclass: wb_transaction_in
`endif