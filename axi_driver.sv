class axi_driver extends uvm_driver#(axi_seq_item);
  `NEW_COMP(axi_driver)
  virtual axi_interface vif;
  axi_seq_item axi_tx;
  
  logic [`ID_BITS-1:0] 	rid[$];
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_resource_db#(virtual axi_interface)::read_by_name("TOP","pif",vif,null))
         `uvm_fatal("INTERFCAE","PIF not set")
        

  endfunction
  
  task run_phase(uvm_phase phase);
     
    wait(vif.rst == 0);
    reset_handshaking();
    forever begin
     @(posedge vif.clk);
      
     seq_item_port.get_next_item(axi_tx);

  	 if (axi_tx == null) begin
    	reset_handshaking();
  	 end
  	 else begin
        //axi_tx.print();
    	drive(axi_tx);
    	seq_item_port.item_done();
        @(posedge vif.clk);
		axi_tx.tx_type = IDLE;
        //`uvm_info("DRIVER CLASS",$sformatf("**** TX_TYPE = %0s****",axi_tx.tx_type),UVM_NONE)
     end
      end
     
  endtask
  
  task drive(axi_seq_item axi_tx);
    //@(posedge vif.clk);

    if(axi_tx.tx_type == WRITE)begin
        //`uvm_info("DRIVER CLASS",$sformatf("**** TX_TYPE = %0s****",axi_tx.tx_type),UVM_NONE)
    	write_address_channel(axi_tx);
    	write_data_channel(axi_tx);
        write_response_channel(axi_tx);

    end
    if(axi_tx.tx_type == READ)begin
		//`uvm_info("DRIVER CLASS",$sformatf("**** TX_TYPE = %0s****",axi_tx.tx_type),UVM_NONE)
    	read_address_channel(axi_tx);
    	read_data_channel(axi_tx);
    end
    
    //`uvm_info("DRIVER CLASS",$sformatf("**** VIF.RLAST = %0d****",vif.rlast),UVM_NONE)
    
    
    
    	
  endtask
  
  task write_address_channel(axi_seq_item axi_tx);
    @(posedge vif.clk);

    vif.awvalid		<=	axi_tx.wr_valid;
  	vif.awaddr  	<=	axi_tx.wr_addr;
	vif.awlen   	<=	axi_tx.wr_len;
	vif.awsize		<=	axi_tx.wr_size;
	vif.awid  		<=	axi_tx.wr_id;  
                                
	vif.awburst		<=	axi_tx.wr_burst;
	vif.awlock		<=	axi_tx.wr_lock;
	vif.awcache		<=	axi_tx.wr_cache;
	vif.awprot		<=	axi_tx.wr_prot;
    
    while(vif.awready==0)begin
    @(posedge vif.clk);
    end
    
    @(posedge vif.clk);
	vif.awready		<=	0;
	vif.awvalid		<=	0;
    
    /*@(posedge vif.clk);
    vif.awaddr  	<=	0;
	vif.awlen   	<=	0;
	vif.awsize		<=	0;
	vif.awid  		<=	0;  
                                
	vif.awresp		<=	0;
	vif.awburst		<=	0;
	vif.awlock		<=	0;
	vif.awcache		<=	0;
	vif.awprot		<=	0;
	vif.awvalid		<=	0;*/
  endtask
  
  task write_data_channel(axi_seq_item axi_tx);
    @(posedge vif.clk);
    vif.wvalid     	<=       axi_tx.wr_valid;
    while(vif.wready==0)begin
    @(posedge vif.clk);
    end
  	vif.wid			<=       axi_tx.wr_id;
	vif.wdata      	<=       axi_tx.wdata;
	vif.wstrb      	<=       axi_tx.wr_strb;
	vif.wlast      	<=       axi_tx.wr_last;
	//vif.wready   	<=       axi_tx.wready;
    
    //while(vif.wready==0)begin
    //@(posedge vif.clk);
    //end 
   
    @(posedge vif.clk);
    vif.wlast   <= 0 ;
    vif.wvalid  <= 0;
  endtask
 
  
  task read_address_channel(axi_seq_item axi_tx);
        @(posedge vif.clk);
    vif.arvalid	<=		axi_tx.rd_valid;
  	vif.araddr	<=		axi_tx.rd_addr;
	vif.arlen	<=		axi_tx.rd_len;
	vif.arsize	<=		axi_tx.rd_size;
	vif.arid  	<=		axi_tx.rd_id;
	vif.arburst	<=		axi_tx.rd_burst;
	vif.arlock	<=		axi_tx.rd_lock;
	vif.arcache	<=		axi_tx.rd_cache;
	vif.arprot	<=		axi_tx.rd_prot;
    
    while(vif.arready==0)begin
    @(posedge vif.clk);
    end 
    //@(posedge vif.clk);
    //wait(vif.rlast);
    //vif.arvalid	<=		0;

                         
	
  endtask
  
  task read_data_channel(axi_seq_item axi_tx);
    vif.rready          	<=         		axi_tx.rd_ready; // todo : assign 0 for read

    @(posedge vif.clk);
    //axi_tx.rd_ready <= 1;

  		axi_tx.rd_id   		   		<=		  vif.rid;   
		axi_tx.rdata           		<=        vif.rdata;
		axi_tx.rd_resp           	<=        vif.rresp;
		axi_tx.rd_last           	<=        vif.rlast;
		axi_tx.rd_valid          	<=        vif.rvalid;
    
    wait(vif.rlast);
    @(posedge vif.clk);
    vif.rready <=0;
    vif.arvalid	<=		0;
    
    while(vif.rvalid==0)begin
    @(posedge vif.clk);
    end    
    //end
    
    
    
    
  endtask
  
  task write_response_channel(axi_seq_item axi_tx);
    vif.bready <= axi_tx.bready;

    @(posedge vif.clk);
  	axi_tx.bid <= vif.bid;
	axi_tx.bresp <= vif.bresp;
    while(vif.bvalid==0)begin
    @(posedge vif.clk);
    end
  
  endtask
  
  task reset_handshaking();
    
    if(vif.wlast==1)begin
        //@(posedge vif.clk);
      	vif.awvalid <= 0;
      	vif.awready <= 0;
    end
    if(vif.bresp==0)begin
        @(posedge vif.clk);

      	//vif.wvalid <= 0;
      	vif.wready <= 0;
        //vif.bvalid <= 0;
      	//vif.bready <= 0;
    end
      	
    if(vif.rlast==1)begin
    	@(posedge vif.clk);
        vif.arready <= 0;
      	vif.rvalid <= 0;
      	//vif.arvalid <= 0;
      end
  endtask


endclass