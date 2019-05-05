`ifndef WB_DRIVER__SV
`define WB_DRIVER__SV

class wb_driver extends uvm_driver #(wb_transaction_in);

	`uvm_component_utils(wb_driver)

	virtual mac_interface wb_vi_if;

  	function new(input string name="wishbone_driver", input uvm_component parent);
    	super.new(name, parent);
  	endfunction : new 

  	//configure the virtual interface
  	virtual function void build_phase(input uvm_phase phase);
    	super.build_phase(phase);
   		uvm_config_db#(virtual mac_interface)::get(this, "", "wb_vi_if", wb_vi_if);
    	if ( drv_vi==null )
      		`uvm_fatal(get_name(), "No virtual interface for wishbone driver.");
  	endfunction : build_phase

  	//configure run phase for wishbone driver
  	//consuming sequence item if there is one
  	//drive ramdom value to the wishbone interface if there is no available sequence item
  	virtual task run_phase(input uvm_phase phase);
  		forever begin
  			seq_item_port.try_next_item(req);//non-blocking varient, will return null if no available sequence item
  			if(req == null) //no available seq item
  			begin
	  			//not trigger transmission
  				wb_vi_if.drv_cb.wb_cyc <= 1'b0;
  				wb_vi_if.drv_cb.wb_stb <= 1'b0;
  			end
  			else
  			begin
  				//trigger the transmission
  				@(wb_vi_if.drv_cb);
  					wb_vi_if.drv_cb.wb_stb <= req.wb_stb;
  					wb_vi_if.drv_cb.wb_cyc <= req.wb_cyc;
  					wb_vi_if.drv_cb.wb_we <= req.wb_we;
  					wb_vi_if.drv_cb.wb_data <= req.wb_data;
  					wb_vi_if.drv_cb.wb_addr <= req.wb_addr;
  				//hold the transmission
  				repeat(5) @(wb_vi_if.drv_cb);
  				//stop the transmission
  				repeat(20) begin
  					wb_vi_if.drv_cb.wb_stb <= 1'b0;
  					wb_vi_if.drv_cb.wb_cyc <= 1'b0;
  				end
  				//handshaking with sequencer
  				seq_item_port.item_done();
  			end
  		end
  	endtask: run_phase 

endclass: wb_driver
`endif