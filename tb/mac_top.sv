
`ifndef MAC_TOP__SV
`define MAC_TOP__SV

module mac_top();

	logic         clk_156m25, clk_xgmii_rx, clk_xgmii_tx, wb_clk_i;
  	logic         reset_156m25_n, reset_xgmii_rx_n, reset_xgmii_tx_n;
	//POS-L3
	logic pkt_rx_ren, pkt_tx_eop, pkt_tx_sop, pkt_tx_val, pkt_rx_avail, pkt_rx_eop, pkt_rx_err, pkt_rx_sop, pkt_rx_val, pkt_tx_full;
	logic [63:0]  pkt_tx_data, pkt_rx_data;
	logic [2:0]   pkt_tx_mod, pkt_rx_mod;
	//Wishbone
	logic wb_cyc_i, wb_stb_i, wb_we_i, wb_ack_o, wb_int_o, wb_rst_i;
	logic [31:0]  wb_dat_i, wb_dat_o;
	logic [7:0]   wb_adr_i;
	//XGMII
	logic [63:0]  xgmii_rxd, xgmii_txd;
	logic [7:0]   xgmii_rxc, xgmii_txc;

	initial 
	begin
    	clk_156m25      <= '0;
    	clk_xgmii_rx    <= '0;
    	clk_xgmii_tx    <= '0;
    	wb_clk_i        <= '0;
    	forever 
    	begin
      		#3200;
      		clk_156m25    = ~clk_156m25;
      		clk_xgmii_rx  = ~clk_xgmii_rx;
      		clk_xgmii_tx  = ~clk_xgmii_tx;
      		wb_clk_i      = ~wb_clk_i;
    	end
  	end
  
  	// Instantiate xge_mac_interface
  	mac_interface   mac_if  (
                            .clk_156m25         (clk_156m25),
                            .clk_xgmii_rx       (clk_xgmii_rx),
                            .clk_xgmii_tx       (clk_xgmii_tx),
                            .wb_clk_i           (wb_clk_i),
                            .reset_156m25_n     (reset_156m25_n),
                            .reset_xgmii_rx_n   (reset_xgmii_rx_n),
                            .reset_xgmii_tx_n   (reset_xgmii_tx_n),
                            .wb_rst_i           (wb_rst_i)
                            );

  	// Instantiate the xge_mac core DUT
  	xge_mac 		dut   	( // Outputs
                            .pkt_rx_avail       (mac_if.pkt_rx_avail),
                            .pkt_rx_data        (mac_if.pkt_rx_data),
                            .pkt_rx_eop         (mac_if.pkt_rx_eop),
                            .pkt_rx_err         (mac_if.pkt_rx_err),
                            .pkt_rx_mod         (mac_if.pkt_rx_mod),
                            .pkt_rx_sop         (mac_if.pkt_rx_sop),
                            .pkt_rx_val         (mac_if.pkt_rx_val),
                            .pkt_tx_full        (mac_if.pkt_tx_full),
                            .wb_ack_o           (mac_if.wb_ack_o),
                            .wb_dat_o           (mac_if.wb_dat_o),
                            .wb_int_o           (mac_if.wb_int_o),
                            .xgmii_txc          (mac_if.xgmii_txc),
                            .xgmii_txd          (mac_if.xgmii_txd),
                            // Inputs
                            .clk_156m25         (clk_156m25),
                            .clk_xgmii_rx       (clk_xgmii_rx),
                            .clk_xgmii_tx       (clk_xgmii_tx),
                            .pkt_rx_ren         (mac_if.pkt_rx_ren),
                            .pkt_tx_data        (mac_if.pkt_tx_data),
                            .pkt_tx_eop         (mac_if.pkt_tx_eop),
                            .pkt_tx_mod         (mac_if.pkt_tx_mod),
                            .pkt_tx_sop         (mac_if.pkt_tx_sop),
                            .pkt_tx_val         (mac_if.pkt_tx_val),
                            .reset_156m25_n     (reset_156m25_n),
                            .reset_xgmii_rx_n   (reset_xgmii_rx_n),
                            .reset_xgmii_tx_n   (reset_xgmii_tx_n),
                            .wb_adr_i           (mac_if.wb_adr_i),
                            .wb_clk_i           (wb_clk_i),
                            .wb_cyc_i           (mac_if.wb_cyc_i),
                            .wb_dat_i           (mac_if.wb_dat_i),
                            .wb_rst_i           (wb_rst_i),
                            .wb_stb_i           (mac_if.wb_stb_i),
                            .wb_we_i            (mac_if.wb_we_i),
                            .xgmii_rxc          (mac_if.xgmii_rxc),
                            .xgmii_rxd          (mac_if.xgmii_rxd)
                          	);
  	
endmodule : mac_top

`endif
