`ifndef XGE_TEST_TOP__SV
`define XGE_TEST_TOP__SV
`timescale 1ps / 1ps 
`include "uvm_macros.svh"
import uvm_pkg::*;
import rst_seq_pkg::*;
import rst_modules_pkg::*;
import wb_seq_pkg::*;
import wb_modules_pkg::*;
import pkt_seq_pkg::*;
import pkt_tx_driver_pkg::*;
import pkt_tx_monitor_pkg::*;
import pkt_tx_agent_pkg::*;
import pkt_rx_monitor_pkg::*;
import pkt_rx_agent_pkg::*;
import scoreboard_pkg::*;
import test_env_pkg::*;
import v_seqr_pkg::*;
import multi_test_pkg::*;


module xge_test_top();

  logic         clk_156m25, clk_xgmii_rx, clk_xgmii_tx;
  logic         reset_156m25_n, reset_xgmii_rx_n, reset_xgmii_tx_n;
  logic         pkt_rx_ren, pkt_tx_eop, pkt_tx_sop, pkt_tx_val;
  logic         wb_clk_i, wb_cyc_i, wb_rst_i, wb_stb_i, wb_we_i;
  logic [63:0]  pkt_tx_data, xgmii_rxd;
  logic [2:0]   pkt_tx_mod;
  logic [7:0]   wb_adr_i, xgmii_rxc;
  logic [31:0]  wb_dat_i;
  logic         pkt_rx_avail, pkt_rx_eop, pkt_rx_err, pkt_rx_sop, pkt_rx_val, pkt_tx_full;
  logic         wb_ack_o, wb_int_o;
  logic [63:0]  pkt_rx_data, xgmii_txd;
  logic [2:0]   pkt_rx_mod;
  logic [31:0]  wb_dat_o;
  logic [7:0]   xgmii_txc;

  // Generate free running clocks
  initial begin
    clk_156m25      <= '0;
    clk_xgmii_rx    <= '0;
    clk_xgmii_tx    <= '0;
    wb_clk_i        <= '0;
    forever begin
      #3200;
      clk_156m25    = ~clk_156m25;
      clk_xgmii_rx  = ~clk_xgmii_rx;
      clk_xgmii_tx  = ~clk_xgmii_tx;
      wb_clk_i      = ~wb_clk_i;
    end
  end

  // Instantiate mac_interface
  mac_interface     mac_if  (
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
  xge_mac   xge_mac_dut   ( // Outputs
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

  initial begin
  uvm_config_db #(virtual mac_interface)::set(null, "uvm_test_top", "dut_config", mac_if);

      uvm_top.set_report_verbosity_level_hier(UVM_HIGH);
      //uvm_top.run_test("basic_test");
      uvm_top.run_test("small_size_test");
      //uvm_top.run_test("big_size_test");
      
  end

endmodule : xge_test_top

`endif
