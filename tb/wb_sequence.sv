`ifndef WB_SEQUENCE__SV
`define WB_SEQUENCE__SV

class wb_sequence_config extends uvm_sequence #(wb_transaction_in);

	`uvm_object_utils(wb_sequence_config)

	function new(input string name="wishbone_init_sequence");
		super.new(name);
    	`uvm_info( get_name(), $sformatf("Hierarchy: %m"), UVM_HIGH )
  	endfunction : new

  	virtual task body();
  	begin
  		// wb_transaction_in tx;
  		// tx=wb_transaction_in::type_id::create("tx");
  		// start_item(tx);
  		// assert(tx.randomize() with {(tx.wb_we == 1'b1) && (tx.wb_addr == 8'h00) && (tx.wb_data == 32'h00000001)} );
  		// finish_item(tx);

  		// wb_transaction_in tx2;
  		// tx2=wb_transaction_in::type_id::create("tx2");
  		// start_item(tx2);
  		// assert(tx2.randomize() with {(tx2.wb_we == 1'b1) && (tx2.wb_addr == 8'h10) && (tx2.wb_data == 32'hFFFFFFFF)} );
  		// finish_item(tx2);

    	//Trigger the transmission of frames
    	`uvm_do_with(req, { wb_we == 1'b1; wb_addr == 8'h00; wb_data == 32'h00000001; wb_stb == 1'b1; wb_cyc == 1'b1;} );
    	//Enable the interrupt
    	`uvm_do_with(req, { wb_we == 1'b1; wb_addr == 8'h10; wb_data == 32'hFFFFFFFF; wb_stb == 1'b1; wb_cyc == 1'b1;} );
  	end
  	endtask : body

  	virtual task pre_start();
    	if ( starting_phase != null )
      		starting_phase.raise_objection( this );
  	endtask : pre_start

  	virtual task post_start();
    	if  ( starting_phase != null )
      		starting_phase.drop_objection( this );
  	endtask : post_start

endclass: wb_sequence_config

class wb_sequence_finish extends uvm_sequence #(wb_transaction_in);

	`uvm_object_utils(wb_sequence_finish)

	function new(input string name="wishbone_init_sequence");
		super.new(name);
    	`uvm_info( get_name(), $sformatf("Hierarchy: %m"), UVM_HIGH )
  	endfunction : new

  	virtual task body();
  	begin
  		// wb_transaction_in tx;
  		// tx=wb_transaction_in::type_id::create("tx");
  		// start_item(tx);
  		// assert(tx.randomize() with {(tx.wb_we == 1'b0) && (tx.wb_addr == 8'h00)} );
  		// finish_item(tx);

  		// wb_transaction_in tx2;
  		// tx2=wb_transaction_in::type_id::create("tx2");
  		// start_item(tx2);
  		// assert(tx2.randomize() with {(tx2.wb_we == 1'b0) && (tx2.wb_addr == 8'h10)} );
  		// finish_item(tx2);

  		// wb_transaction_in tx3;
  		// tx3=wb_transaction_in::type_id::create("tx3");
  		// start_item(tx3);
  		// assert(tx3.randomize() with {(tx3.wb_we == 1'b0) && (tx3.wb_addr == 8'h0C)} );
  		// finish_item(tx3);

  		// wb_transaction_in tx4;
  		// tx4=wb_transaction_in::type_id::create("tx4");
  		// start_item(tx4);
  		// assert(tx4.randomize() with {(tx4.wb_we == 1'b0) && (tx4.wb_addr == 8'h10)} );
  		// finish_item(tx4);

   		//Read the final values from wishbone registers
   		`uvm_do_with(req, { wb_we == 1'b0; wb_addr == 8'h00; wb_stb == 1'b1; wb_cyc == 1'b1;} );
    	`uvm_do_with(req, { wb_we == 1'b0; wb_addr == 8'h08; wb_stb == 1'b1; wb_cyc == 1'b1;} );
    	`uvm_do_with(req, { wb_we == 1'b0; wb_addr == 8'h0C; wb_stb == 1'b1; wb_cyc == 1'b1;} );
    	`uvm_do_with(req, { wb_we == 1'b0; wb_addr == 8'h10; wb_stb == 1'b1; wb_cyc == 1'b1;} );
  	end
  	endtask : body

  	virtual task pre_start();
    	if ( starting_phase != null )
      		starting_phase.raise_objection( this );
  	endtask : pre_start

  	virtual task post_start();
    	if  ( starting_phase != null )
      		starting_phase.drop_objection( this );
  	endtask : post_start

endclass: wb_sequence_finish


`endif