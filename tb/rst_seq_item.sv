

`ifndef RST_SEQ_ITEM__SV
`define RST_SEQ_ITEM__SV

`include "uvm_macros.svh"

import uvm_pkg::*;

class rst_transaction_in extends uvm_sequence_item;

    `uvm_object_utils(rst_transaction_in)
	rand logic rst_156m25_n, rst_xgmii_rx_n, rst_xgmii_tx_n, wb_rst;

    function new(input string name = "rst_transaction_in");
        super.new(name);
    endfunction: new

endclass: rst_transaction_in
`endif
