//*********************************************
//          UVM Based Verification of         *
//           10 Gb Ethernet MAC Core          *
//                                            *
// Team member: Xuezhi Teng (xt2276)          *
//              Yi Zheng    (yz24299)         *
//*********************************************

//This is tx_driver file. It is used to driver the sequence from the tx_sequencer into the interface
`include "uvm_macros.svh"
package pkt_tx_driver_pkg;
import uvm_pkg::*;
import pkt_seq_pkg::*;


class tx_driver extends uvm_driver #(tx_transaction);

  virtual mac_interface     drv_vi;

  `uvm_component_utils( tx_driver )

  function new(input string name="tx_driver", input uvm_component parent);
    super.new(name, parent);
  endfunction : new


  virtual function void build_phase(input uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(virtual mac_interface)::get(this, "", "drv_vi", drv_vi);
    if ( drv_vi==null )
      `uvm_fatal(get_name(), "Virtual Interface for driver not set!");
  endfunction : build_phase


  virtual task run_phase(input uvm_phase phase);
    int unsigned    pkt_len_in_bytes;
    int unsigned    num_of_flits;
    bit [2:0]       last_flit_mod;
    bit [63:0]      tx_data;

    `uvm_info( get_name(), $sformatf("HIERARCHY: %m"), UVM_HIGH);
    forever begin
      seq_item_port.try_next_item( req );
      if ( req == null ) begin
        // Send random idle
        @(drv_vi.drv_cb);
        drv_vi.drv_cb.pkt_tx_val    <= 1'b0;
        drv_vi.drv_cb.pkt_tx_sop    <= $urandom_range(1,0);
        drv_vi.drv_cb.pkt_tx_eop    <= $urandom_range(1,0);
        drv_vi.drv_cb.pkt_tx_mod    <= $urandom_range(7,0);
        drv_vi.drv_cb.pkt_tx_data   <= { $urandom, $urandom_range(65535,0) };
      end
      else begin
        `uvm_info( get_name(), $psprintf("Packet: \n%0s", req.sprint()), UVM_HIGH)
        pkt_len_in_bytes    = 6 + 6 + 2 + req.payload.size(); 
        num_of_flits        = ( pkt_len_in_bytes%8 ) ? pkt_len_in_bytes/8 + 1 : pkt_len_in_bytes/8;
        last_flit_mod       = pkt_len_in_bytes%8;
        `uvm_info( get_name(), $psprintf("pkt_len_in_bytes=%0d, num_of_flits=%0d, last_flit_mod=%0d",
                                pkt_len_in_bytes, num_of_flits, last_flit_mod), UVM_FULL)
        for ( int i=0; i<num_of_flits; i++ ) begin
          tx_data = 64'h0;
          @(drv_vi.drv_cb);
          if ( i==0 )  
		  begin    //Start of Packet
            tx_data = { req.dst_addr, req.src_addr[47:32] };
            drv_vi.drv_cb.pkt_tx_val  <= 1'b1;
            drv_vi.drv_cb.pkt_tx_sop  <= req.set_sop;
            drv_vi.drv_cb.pkt_tx_eop  <= 1'b0;
            drv_vi.drv_cb.pkt_tx_mod  <= $urandom_range(7,0);
            drv_vi.drv_cb.pkt_tx_data <= tx_data;
          end                 
		  
          else if ( i==(num_of_flits-1) ) 
		  begin // End of Packet
            if ( num_of_flits==2 ) begin
              tx_data[63:16] = { req.src_addr[31:0], req.ethernet_type };
              tx_data[15:0]  = $urandom_range(16'hFFFF,0);
              for ( int j=0; j<req.payload.size(); j++ ) begin
                if ( j==0 ) begin
                  tx_data[15:8] = req.payload[0];
                end
                else begin
                  tx_data[7:0]  = req.payload[1];
                end
              end
            end
            else begin
              for ( int j=0; j<8; j++ ) begin
                if (j<(((req.payload.size()-3)%8)+1)) begin
                  tx_data = tx_data | ( req.payload[8*(i-1)+j-6] << (56-8*j) );
                end
                else begin
                  tx_data = tx_data | ( $urandom_range(8'hFF,0) << (56-8*j) );
                end
              end
            end
            drv_vi.drv_cb.pkt_tx_val  <= 1'b1;
            drv_vi.drv_cb.pkt_tx_sop  <= 1'b0;
            drv_vi.drv_cb.pkt_tx_eop  <= req.set_eop;
            drv_vi.drv_cb.pkt_tx_mod  <= last_flit_mod;
            drv_vi.drv_cb.pkt_tx_data <= tx_data;
          end                  
		  
          else 
		  begin            //Middle of Pakect
            if ( i==1 ) begin
              tx_data = { req.src_addr[31:0], req.ethernet_type, req.payload[0], req.payload[1] };
            end
            else begin
              for ( int j=0; j<8; j++ ) begin
                tx_data = (tx_data<<8) | req.payload[8*(i-1)+j-6];
              end
            end
            drv_vi.drv_cb.pkt_tx_val  <= 1'b1;
            drv_vi.drv_cb.pkt_tx_sop  <= 1'b0;
            drv_vi.drv_cb.pkt_tx_eop  <= 1'b0;
            drv_vi.drv_cb.pkt_tx_mod  <= $urandom_range(0,7);
            drv_vi.drv_cb.pkt_tx_data <= tx_data;
          end               
        end
        repeat ( req.inter_gap ) begin
          @(drv_vi.drv_cb);
          drv_vi.drv_cb.pkt_tx_val    <= 1'b0;
          drv_vi.drv_cb.pkt_tx_sop    <= $urandom_range(1,0);
          drv_vi.drv_cb.pkt_tx_eop    <= $urandom_range(1,0);
          drv_vi.drv_cb.pkt_tx_mod    <= $urandom_range(7,0);
          drv_vi.drv_cb.pkt_tx_data   <= { $urandom, $urandom_range(65535,0) };
        end
        while ( drv_vi.drv_cb.pkt_tx_full ) begin
          // When the pkt_tx_full signal is asserted, transfers should
          // be suspended at the end of the current packet.  Transfer of
          // next packet can begin as soon as this signal is de-asserted.
          @(drv_vi.drv_cb);
          drv_vi.drv_cb.pkt_tx_val    <= 1'b0;
          drv_vi.drv_cb.pkt_tx_sop    <= $urandom_range(1,0);
          drv_vi.drv_cb.pkt_tx_eop    <= $urandom_range(1,0);
          drv_vi.drv_cb.pkt_tx_mod    <= $urandom_range(7,0);
          drv_vi.drv_cb.pkt_tx_data   <= { $urandom, $urandom_range(65535,0) };
        end
        // Communicate item done to the sequencer
        seq_item_port.item_done();
      end
    end
  endtask : run_phase

endclass : tx_driver

endpackage : pkt_tx_driver_pkg
