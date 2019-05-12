//*********************************************
//          UVM Based Verification of         *
//           10 Gb Ethernet MAC Core          *
//                                            *
// Team member: Xuezhi Teng (xt2276)          *
//              Yi Zheng    (yz24299)         *
//*********************************************
`include "uvm_macros.svh"
package pkt_rx_monitor_pkg;
import uvm_pkg::*;
import pkt_seq_pkg::*;


class rx_monitor extends uvm_monitor;

  virtual mac_interface     mon_vi;
  int unsigned                  m_num_captured;
  uvm_analysis_port #(tx_transaction)   rx_monitor_aport;

  `uvm_component_utils( rx_monitor )

  function new(input string name="rx_monitor", input uvm_component parent);
    super.new(name, parent);
  endfunction : new


  virtual function void build_phase(input uvm_phase phase);
    super.build_phase(phase);
    m_num_captured = 0;
    rx_monitor_aport = new ( "rx_monitor_aport", this );
    uvm_config_db#(virtual mac_interface)::get(this, "", "mon_vi", mon_vi);
  endfunction : build_phase


  virtual task run_phase(input uvm_phase phase);
    tx_transaction      rcv_pkt;
    bit         pkt_in_progress = 0;  //flag for transmission in progress of multi flits
    bit         err_in_packet = 0;    //flag for error occurance
    bit [7:0]   rx_data_q[$];         //buffer for payload
    int         idx;                  //byte counter
    bit         packet_captured = 0;  //transmission finish for one packet

    `uvm_info( get_name(), $sformatf("HIERARCHY: %m"), UVM_HIGH);
    //not trigger read enable
    mon_vi.mon_cb.pkt_rx_ren    <= 1'b0;

    forever begin
      @(mon_vi.mon_cb)
      begin
        if ( mon_vi.mon_cb.pkt_rx_avail ) begin
          mon_vi.mon_cb.pkt_rx_ren <= 1'b1;
        end
        if ( mon_vi.mon_cb.pkt_rx_val ) begin
          if ( mon_vi.mon_cb.pkt_rx_sop && !mon_vi.mon_cb.pkt_rx_eop && pkt_in_progress==0 ) 
		  begin
		  //Multi Flit Transmission
            // -------------------------------- SOP cycle ----------------
            rcv_pkt = tx_transaction::type_id::create("rcv_pkt", this);
            pkt_in_progress = 1;
            mon_vi.mon_cb.pkt_rx_ren <= 1'b1;
            rcv_pkt.set_sop            = mon_vi.mon_cb.pkt_rx_sop;
            rcv_pkt.dst_addr        = mon_vi.mon_cb.pkt_rx_data[63:16];
            rcv_pkt.src_addr[47:32] = mon_vi.mon_cb.pkt_rx_data[15:0];
            rcv_pkt.src_addr[31:0]  = 32'h0;
            rcv_pkt.ethernet_type          = 16'h0;
            rcv_pkt.payload = new[0];
            while ( rx_data_q.size()>0 ) begin
              rx_data_q.pop_front();
            end
          end   // ---------------------------- SOP cycle ----------------
          if ( !mon_vi.mon_cb.pkt_rx_sop && !mon_vi.mon_cb.pkt_rx_eop && pkt_in_progress==1 ) 
		  begin
            // -------------------------------- MOP cycle ----------------
            pkt_in_progress = 1;
            mon_vi.mon_cb.pkt_rx_ren <= 1'b1;
            if ( rx_data_q.size()==0 ) begin
              rcv_pkt.src_addr[31:0]  = mon_vi.mon_cb.pkt_rx_data[63:32];
              rcv_pkt.ethernet_type          = mon_vi.mon_cb.pkt_rx_data[31:16];
              rx_data_q.push_back(mon_vi.mon_cb.pkt_rx_data[15:8]);
              rx_data_q.push_back(mon_vi.mon_cb.pkt_rx_data[7:0]);
            end
            else begin
              for ( int i=0; i<8; i++ ) begin
                rx_data_q.push_back( (mon_vi.mon_cb.pkt_rx_data >> (64-8*(i+1))) & 8'hFF );
              end
            end
          end   
          if ( mon_vi.mon_cb.pkt_rx_eop && pkt_in_progress==1 ) 
		  begin
            // -------------------------------- EOP cycle ----------------
            rcv_pkt.set_eop= mon_vi.mon_cb.pkt_rx_eop;
            pkt_in_progress = 0;
            err_in_packet   = mon_vi.mon_cb.pkt_rx_err;
            mon_vi.mon_cb.pkt_rx_ren <= 1'b0;
            if(rx_data_q.size()==0)	//two flits
          				begin
            				rcv_pkt.src_addr[31:0]  = mon_vi.mon_cb.pkt_tx_data[63:32];
            				rcv_pkt.ethernet_type   = mon_vi.mon_cb.pkt_tx_data[31:16];
            				if ( mon_vi.mon_cb.pkt_tx_mod==0 )
            				begin
              					rx_data_q.push_back(mon_vi.mon_cb.pkt_tx_data[15:8]);
              					rx_data_q.push_back(mon_vi.mon_cb.pkt_tx_data[7:0]);
            				end
            				else if ( mon_vi.mon_cb.pkt_tx_mod==7 )
            				begin
              					rx_data_q.push_back(mon_vi.mon_cb.pkt_tx_data[15:8]);
            				end
          				end
			
			else 
			begin  //more than two flits
				if ( mon_vi.mon_cb.pkt_rx_mod==0 ) 
				begin
				for ( int i=0; i<8; i++ ) 
					begin
						rx_data_q.push_back( (mon_vi.mon_cb.pkt_rx_data >> (64-8*(i+1))) & 8'hFF );
					end
				end
				else 
				begin
					for ( int i=0; i<mon_vi.mon_cb.pkt_rx_mod; i++ ) 
					begin
						rx_data_q.push_back( (mon_vi.mon_cb.pkt_rx_data >> (64-8*(i+1))) & 8'hFF );
					end
				end
			end	
			
            rcv_pkt.payload = new[rx_data_q.size()];
            idx = 0;
            while ( rx_data_q.size()>0 ) begin
              rcv_pkt.payload[idx]  = rx_data_q.pop_front();
              idx++;
            end
            packet_captured  = 1;
            // -------------------------------- EOP cycle ----------------
          end
          if ( mon_vi.mon_cb.pkt_rx_sop && mon_vi.mon_cb.pkt_rx_eop && pkt_in_progress==0) begin
            // -------------------------------- SOP/EOP cycle ------------
            rcv_pkt = tx_transaction::type_id::create("rcv_pkt", this);
            err_in_packet   = mon_vi.mon_cb.pkt_rx_err;
            mon_vi.mon_cb.pkt_rx_ren <= 1'b0;
            rcv_pkt.set_sop            = mon_vi.mon_cb.pkt_rx_sop;
            rcv_pkt.set_eop            = mon_vi.mon_cb.pkt_rx_eop;
            rcv_pkt.dst_addr        = mon_vi.mon_cb.pkt_rx_data[63:16];
            rcv_pkt.src_addr[47:32] = mon_vi.mon_cb.pkt_rx_data[15:0];
            rcv_pkt.src_addr[31:0]  = 32'h0;
            rcv_pkt.ethernet_type          = 16'h0;
            rcv_pkt.payload = new[0];
            while ( rx_data_q.size()>0 ) begin
              rx_data_q.pop_front();
            end
            packet_captured = 1;
            // -------------------------------- SOP/EOP cycle ------------
          end
          if ( packet_captured ) begin
            `uvm_info( get_name(), $psprintf("Packet: \n%0s", rcv_pkt.sprint()), UVM_HIGH)
            if ( !err_in_packet && rcv_pkt.set_sop && rcv_pkt.set_eop ) begin
              rx_monitor_aport.write( rcv_pkt );
              m_num_captured++;
            end
            packet_captured = 0;
          end
        end
      end
    end
  endtask : run_phase


  function void report_phase( uvm_phase phase );
    `uvm_info( get_name( ), $sformatf( "REPORT: Captured %0d packets", m_num_captured ), UVM_LOW )
  endfunction : report_phase

endclass : rx_monitor

endpackage : pkt_rx_monitor_pkg
