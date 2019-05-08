`ifndef RX_MONITOR__SV
`define RX_MONITOR__SV

class rx_monitor extends uvm_monitor;

	`uvm_component_utils(rx_moniter)
	uvm_analysis_port #(tx_transaction) rx_mon_aport;

	virtual mac_interface mon_vi;
	int unsigned rx_mon_num;

	function new(input string name = "rx_monitor", input uvm_component parent);
		super.new(name, parent);
	endfunction : new

	virtual function void build_phase (input uvm_phase);
		rx_mon_num = 0;
		rx_mon_aport = new ("rx_mon_aport", this);
		uvm_config_db#(virtual mac_interface)::get(this, "", "mon_vi", mon_vi);
		if (mon_vi == null)
			`uvm_fatal(get_name(), "Virtual interface for monitor not found!");
	endfunction : build_phase

	virtual task run_phase (input uvm_phase phase);
		tx_transaction      rx_packet;
		bit         pkt_in_progress = 0;    //flag for transmission in progress of multi flits
    	bit         err_in_packet = 0;		//flag for error occurance
    	bit [7:0]   rx_data_q[$];   		//buffer for payload
    	int         ii;						//byte counter
    	bit         pkt_fihished = 0;		//transmission finish for one packet

    	`uvm_info( get_name(), $sformatf("HIERARCHY: %m"), UVM_HIGH);
    	//not trigger read enable
    	mon_vi.mon_cb.pkt_rx_ren    <= 1'b0;
    	forever
    	begin
    		@(mon_vi.mon_cb)
    		begin
    			if(mon_vi.mon_cb.pkt_rx_avail)
    			begin
    				//trigger read from rx dequeue
    				mon_vi.mon_cb.pkt_rx_ren <= 1'b1;
    			end
    			if(mon_vi.mon_cb.pkt_rx_val)	//data valid for transmission
    			begin
    				//Multi Flit Transmission
    				// -------------------------------- SOP cycle begin----------------
    				if ( mon_vi.mon_cb.pkt_rx_sop && !mon_vi.mon_cb.pkt_rx_eop && pkt_in_progress==0 )
    				begin
    					rx_packet = tx_transaction::type_id::create("rx_packet", this);
    					pkt_in_progress = 1;
    					mon_vi.mon_cb.pkt_rx_ren  <= 1'b1;
    					rx_packet.set_sop		  = mon_vi.mon_cb.pkt_rx_sop;
          				rx_packet.dst_addr        = mon_vi.mon_cb.pkt_tx_data[63:16];
          				rx_packet.src_addr[47:32] = mon_vi.mon_cb.pkt_tx_data[15:0];
          				rx_packet.src_addr[31:0]  = 32'h0;
          				rx_packet.ethernet_type   = 16'h0;
          				tx_packet.payload = new[0];	//allocate memory for payload
          				while ( rx_data_q.size()>0 ) begin  //pop out everything
            				rx_data_q.pop_front();
          				end
    				end	
    				// -------------------------------- SOP cycle end------------------
    				// -------------------------------- MOP cycle begin----------------
					if(!mon_vi.mon_cb.pkt_rx_sop && !mon_vi.mon_cb.pkt_rx_eop && pkt_in_progress==1)
    				begin
    					pkt_in_progress = 1;
    					mon_vi.mon_cb.pkt_rx_ren <= 1'b1;
          				if ( rx_data_q.size()==0 ) 
          				begin
            				rx_packet.src_addr[31:0]  = mon_vi.mon_cb.pkt_tx_data[63:32];
            				rx_packet.ethernet_type   = mon_vi.mon_cb.pkt_tx_data[31:16];
            				rx_data_q.push_back(mon_vi.mon_cb.pkt_tx_data[15:8]);
            				rx_data_q.push_back(mon_vi.mon_cb.pkt_tx_data[7:0]);
          				end
          				else begin
				            for ( int i=0; i<8; i++ ) begin
				            	rx_data_q.push_back( (mon_vi.mon_cb.pkt_tx_data >> (64-8*(i+1))) & 8'hFF );
				            end
          				end
    				end
    				// -------------------------------- MOP cycle end------------------
    				// -------------------------------- EOP cycle begin----------------
    				if(mon_vi.mon_cb.pkt_rx_eop && pkt_in_progress==1)
    				begin
    					tx_packet.set_eop = mon_vi.mon_cb.pkt_tx_eop;
    					pkt_in_progress   = 0;	//finish progress
    					err_in_packet	  = mon_vi.mon_cb.pkt_rx_err;	//error flag
    					mon_vi.mon_cb.pkt_rx_ren <= 1'b0;
          				if(rx_data_q.size()==0)	//two flits
          				begin
            				rx_packet.src_addr[31:0]  = mon_vi.mon_cb.pkt_tx_data[63:32];
            				rx_packet.ethernet_type   = mon_vi.mon_cb.pkt_tx_data[31:16];
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
          				begin					//more than two flits
            				if ( mon_vi.mon_cb.pkt_tx_mod==0 )
            				begin
              					for ( int i=0; i<8; i++ )
              					begin
                					rx_data_q.push_back( (mon_vi.mon_cb.pkt_tx_data >> (64-8*(i+1))) & 8'hFF );
              					end
            				end
	            			else 
	            			begin
	              				for ( int i=0; i<mon_vi.mon_cb.pkt_tx_mod; i++ )
	              				begin
	                				rx_data_q.push_back( (mon_vi.mon_cb.pkt_tx_data >> (64-8*(i+1))) & 8'hFF );
	              				end
	            			end
          				end

          				tx_packet.payload = new[rx_data_q.size()];
          				ii = 0;
            			while ( rx_data_q.size()>0 ) begin
              				tx_packet.payload[ii]  = rx_data_q.pop_front();
              				ii++;
            			end
            			pkt_fihished = 1;
    				end
    				// -------------------------------- EOP cycle end------------------

    				//Single flit
    				// -------------------------------- Single cycle begin-------------
    				if(mon_vi.mon_cb.pkt_rx_sop && mon_vi.mon_cb.pkt_rx_eop && pkt_in_progress==0)
    				begin
    					rx_packet = tx_transaction::type_id::create("rx_packet", this);
    					err_in_packet   			  = mon_vi.mon_cb.pkt_rx_err;
    					mon_vi.mon_cb.pkt_rx_ren 	  <= 1'b0;	//disable read enable
			            tx_packet.sop_mark            = mon_vi.mon_cb.pkt_rx_sop;
			            tx_packet.eop_mark            = mon_vi.mon_cb.pkt_rx_eop;
			            tx_packet.mac_dst_addr        = mon_vi.mon_cb.pkt_rx_data[63:16];
			            tx_packet.mac_src_addr[47:32] = mon_vi.mon_cb.pkt_rx_data[15:0];
			            tx_packet.mac_src_addr[31:0]  = 32'h0;
			            tx_packet.ether_type          = 16'h0;
			            tx_packet.payload = new[0];
			            while ( rx_data_q.size()>0 ) begin
			              	rx_data_q.pop_front();	//clear buffer fifo
			            end
			            pkt_fihished = 1;
    				end

          			//copy data into payload
          			if (pkt_fihished) 
          			begin
            			`uvm_info( get_name(), $psprintf("Packet: \n%0s", tx_packet.sprint()), UVM_HIGH)
            			if( !err_in_packet && rcv_pkt.sop_mark && rcv_pkt.eop_mark)
            			begin
              				ap_rx_mon.write( rcv_pkt );
              				rx_mon_num++;
            			end
            			pkt_fihished = 0;
          			end
    			end
    		end
    	end
    endtask : run_phase

  	function void report_phase( uvm_phase phase );
    	`uvm_info( get_name( ), $sformatf( "REPORT: Captured %0d packets", rx_mon_num ), UVM_LOW )
  	endfunction : report_phase 
endclass: rx_monitor

`endif