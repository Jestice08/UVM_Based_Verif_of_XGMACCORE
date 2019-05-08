//This is tx_moniter
//Designed by Xuezhi Teng
`ifndef  TX_MONITOR_SV
`define  TX_MONITOR_SV


class tx_monitor extends uvm_monitor;

	`uvm_component_utils(tx_moniter)
	
	uvm_analysis_port #(tx_transaction) tx_mon_aport;
	
	virtual mac_interface mon_vi;
	int unsigned tx_mon_num;
	
	function new(input string name = "tx_monitor", input uvm_component parent);
		super.new(name, parent);
	endfunction : new
	
	virtual function void build_phase (input uvm_phase);
		//super.build_phase(phase);
		tx_mon_num = 0;
		tx_mon_aport = new ("tx_mon_aport", this);
		uvm_config_db#(virtual mac_interface)::get(this, "", "mon_vi", mon_vi);
		if (mon_vi == null)
			`uvm_fatal(get_name(), "Virtual interface for monitor not found!");
	endfunction : build_phase
	
	virtual task run_phase (input uvm_phase phase);
	
	tx_transaction      tx_packet;
	
    bit         pkt_in_progress = 0;    //this is just a flag bit to tell you that something is being tranmitted
    bit [7:0]   tx_data_q[$];   //This is a queue, it is used for storing the tx_data temporily
    int         ii;
    bit         pkt_fihished = 0;

    `uvm_info( get_name(), $sformatf("HIERARCHY: %m"), UVM_HIGH);

    forever begin
      @(mon_vi.mon_cb)
      if ( mon_vi.mon_cb.pkt_tx_val ) begin
        if ( mon_vi.mon_cb.pkt_tx_sop && !mon_vi.mon_cb.pkt_tx_eop && pkt_in_progress==0 ) 
		begin  
		// -------------------------------- SOP cycle begin----------------
          tx_packet = tx_transaction::type_id::create("tx_packet", this);
          pkt_in_progress = 1;
          tx_packet.set_sop         = mon_vi.mon_cb.pkt_tx_sop;
          tx_packet.dst_addr        = mon_vi.mon_cb.pkt_tx_data[63:16];
          tx_packet.src_addr[47:32] = mon_vi.mon_cb.pkt_tx_data[15:0];
          tx_packet.src_addr[31:0]  = 32'h0;
          tx_packet.ethernet_type   = 16'h0;
          tx_packet.payload = new[0];
          while ( tx_data_q.size()>0 ) begin  //pop out everything
            tx_data_q.pop_front();
          end
        end   
		// ---------------------------- SOP cycle end----------------
        
		
		if ( !mon_vi.mon_cb.pkt_tx_sop && !mon_vi.mon_cb.pkt_tx_eop && pkt_in_progress==1 ) 
		begin  
		// -------------------------------- MOP cycle begin----------------
          pkt_in_progress = 1;
          if ( tx_data_q.size()==0 ) begin
            tx_packet.src_addr[31:0]  = mon_vi.mon_cb.pkt_tx_data[63:32];
            tx_packet.ethernet_type   = mon_vi.mon_cb.pkt_tx_data[31:16];
            tx_data_q.push_back(mon_vi.mon_cb.pkt_tx_data[15:8]);
            tx_data_q.push_back(mon_vi.mon_cb.pkt_tx_data[7:0]);
          end
          else begin
            for ( int i=0; i<8; i++ ) begin
              tx_data_q.push_back( (mon_vi.mon_cb.pkt_tx_data >> (64-8*(i+1))) & 8'hFF );
            end
          end
        end   
		// ---------------------------- MOP cycle end----------------
        
		if ( mon_vi.mon_cb.pkt_tx_eop && pkt_in_progress==1 ) 
		begin  
		// -------------------------------- EOP cycle begin----------------
          tx_packet.set_eop= mon_vi.mon_cb.pkt_tx_eop;
          pkt_in_progress = 0;
          if ( tx_data_q.size()==0 ) begin
            tx_packet.src_addr[31:0]  = mon_vi.mon_cb.pkt_tx_data[63:32];
            tx_packet.ethernet_type   = mon_vi.mon_cb.pkt_tx_data[31:16];
            if ( mon_vi.mon_cb.pkt_tx_mod==0 ) begin
              tx_data_q.push_back(mon_vi.mon_cb.pkt_tx_data[15:8]);
              tx_data_q.push_back(mon_vi.mon_cb.pkt_tx_data[7:0]);
            end
            else if ( mon_vi.mon_cb.pkt_tx_mod==7 ) begin
              tx_data_q.push_back(mon_vi.mon_cb.pkt_tx_data[15:8]);
            end
          end
          
		  else begin
            if ( mon_vi.mon_cb.pkt_tx_mod==0 ) begin
              for ( int i=0; i<8; i++ ) begin
                tx_data_q.push_back( (mon_vi.mon_cb.pkt_tx_data >> (64-8*(i+1))) & 8'hFF );
              end
            end
            else begin
              for ( int i=0; i<mon_vi.mon_cb.pkt_tx_mod; i++ ) begin
                tx_data_q.push_back( (mon_vi.mon_cb.pkt_tx_data >> (64-8*(i+1))) & 8'hFF );
              end
            end
          end
          tx_packet.payload = new[tx_data_q.size()];
          ii = 0;
          while ( tx_data_q.size()>0 ) begin
            tx_packet.payload[ii]  = tx_data_q.pop_front();
            ii++;
          end
          pkt_fihished  = 1;
        end   
		// -------------------------------- EOP cycle end----------------
        
		
		if ( pkt_fihished ) begin
          `uvm_info( get_name(), $psprintf("Packet: \n%0s", tx_packet.sprint()), UVM_HIGH)
          if ( tx_packet.set_sop && tx_packet.set_eop ) begin
            ap_tx_mon.write( tx_packet );
            tx_mon_num++;
          end
          pkt_fihished = 0;
        end
      end
    end
  endtask : run_phase


  function void report_phase( uvm_phase phase );
    `uvm_info( get_name( ), $sformatf( "REPORT: Captured %0d packets", tx_mon_num ), UVM_LOW )
  endfunction : report_phase

endclass : tx_monitor

`endif  //TX_MONITOR__SV
	
