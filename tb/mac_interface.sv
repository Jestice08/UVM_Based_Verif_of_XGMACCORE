`ifndef MAC_INTERFACE__SV
`define MAC_INTERFACE__SV

interface mac_interface(
);
//POS-L3
logic pkt_rx_ren, pkt_tx_eop, pkt_tx_sop, pkt_tx_val, pkt_rx_avail, pkt_rx_eop, pkt_rx_err, pkt_rx_sop, pkt_rx_val, pkt_tx_full;
logic [63:0]  pkt_tx_data, pkt_rx_data;
logic [2:0]   pkt_tx_mod, pkt_rx_mod;
//Wishbone
logic wb_cyc_i, wb_stb_i, wb_we_i, wb_ack_o, wb_int_o;
logic [31:0]  wb_dat_i, wb_dat_o;
logic [7:0]   wb_adr_i;
//XGMII
logic [63:0]  xgmii_rxd, xgmii_txd;
logic [7:0]   xgmii_rxc, xgmii_txc;


endinterface: mac_interface
`endif
