class axi_monitor extends uvm_monitor;
  `NEW_COMP(axi_monitor)
  uvm_analysis_port #(axi_seq_item) mon_ap;
  axi_seq_item axi_tx_mon;
  virtual axi_interface vif;
  //write_response_t write_response;
	int rd_req_num=0,wr_req_num=0;
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    axi_tx_mon = axi_seq_item::type_id::create("axi_tx_mon");
    mon_ap = new("mon_ap",this);
    if(!uvm_resource_db#(virtual axi_interface)::read_by_name("TOP","pif",vif,null))
      `uvm_fatal(get_full_name(),"VIF calling failed")
      
	//uvm_config_db#(write_response_t)::set(null,"*","write_resp_dut",write_response);

  endfunction
  
  task run_phase(uvm_phase phase);
    
    wait(vif.rst==0);
    forever begin
      @(posedge vif.clk);
      axi_tx_mon.tx_type=WRITE;
      do_handshaking(axi_tx_mon);

      if(vif.wvalid && vif.wready && vif.wlast)begin
          axi_tx_mon.tx_type=WRITE;
       	  write_address_channel_mon(axi_tx_mon);
      	  write_data_channel_mon(axi_tx_mon);
          axi_config::write_request_q.push_back(axi_tx_mon);
        /*
        $display("**************** %0t MONITOR DISPLAY WRITE TX START****************",$time);
        axi_tx_mon.print();
        $display("**************** %0t MONITOR DISPLAY WRITE TX END****************",$time);
        */  		
        mon_ap.write(axi_tx_mon);
      end
      
      if((vif.bresp==0))begin
          axi_tx_mon.tx_type=WRITE_RESP;
      	  write_response_channel(axi_tx_mon);
          mon_ap.write(axi_tx_mon);
          /*
          $display("**************** %0t MONITOR DISPLAY WRITE RESPONSE TX START****************",$time);
          axi_tx_mon.print_write_response();
          $display("********************** %0t MONITOR DISPLAY RESP TX END**********************",$time);
      	  */
      end
      
      axi_tx_mon.tx_type=READ;
      //if(axi_tx_mon.tx_type==READ)begin
      do_handshaking(axi_tx_mon);
      if((vif.rresp==0) && vif.rlast)begin
      	//if(vif.arvalid && vif.arready)
        	//read_address_channel_mon(axi_tx_mon);
      	if(vif.rvalid && vif.rready)
          axi_tx_mon.tx_type=READ;
            read_address_channel_mon(axi_tx_mon);
          axi_tx_mon.tx_type=READ_RESP;

       		read_data_channel_mon(axi_tx_mon);
        //end

        /*
        $display("**************** %0t MONITOR DISPLAY READ TX START****************",$time);
        axi_tx_mon.print();
        $display("**************** %0t MONITOR DISPLAY READ TX END****************",$time);
		*/
        mon_ap.write(axi_tx_mon);

      end// if((vif.rresp==0) && vif.rlast)
      axi_tx_mon.tx_type=IDLE;

    end
  endtask
        
        
task write_address_channel_mon(axi_seq_item axi_tx_mon);
       axi_tx_mon.wr_addr 		=	vif.awaddr; 
       axi_tx_mon.wr_len  		=	vif.awlen  ;
       axi_tx_mon.wr_size   	=	vif.awsize ;
       axi_tx_mon.wr_id	    	=	vif.awid   ;
                                                   
       axi_tx_mon.wr_burst		=	vif.awburst;
       axi_tx_mon.wr_lock   	=	vif.awlock ;
       axi_tx_mon.wr_cache		=	vif.awcache;
       axi_tx_mon.wr_prot   	=	vif.awprot ;
       axi_tx_mon.wr_valid		=	vif.awvalid;
       axi_tx_mon.wr_ready		=	vif.awready;
    
  endtask
  
  task write_data_channel_mon(axi_seq_item axi_tx_mon);
       axi_tx_mon.wr_id       	=       vif.wid ;  
       axi_tx_mon.wdata       	=       vif.wdata; 
       axi_tx_mon.wr_strb     	=       vif.wstrb ;
       axi_tx_mon.wr_last     	=       vif.wlast ;
       axi_tx_mon.wr_valid     	=       vif.wvalid;
       axi_tx_mon.wr_ready   	=       vif.wready;
    
    
  endtask
 
  
  task read_address_channel_mon(axi_seq_item axi_tx_mon);
       axi_tx_mon.rd_addr   =		vif.araddr; 
       axi_tx_mon.rd_len    =		vif.arlen  ;
       axi_tx_mon.rd_size   =		vif.arsize ;
       axi_tx_mon.rd_id     =		vif.arid   ;
       axi_tx_mon.rd_burst	=		vif.arburst;
       axi_tx_mon.rd_lock   =		vif.arlock ;
       axi_tx_mon.rd_cache	=		vif.arcache;
       axi_tx_mon.rd_prot   =		vif.arprot ;
                                                   
       axi_tx_mon.rd_valid	=		vif.arvalid;
       axi_tx_mon.rd_ready	=		vif.arready;
  endtask
  
  task read_data_channel_mon(axi_seq_item axi_tx_mon);
    	//axi_tx.rd_ready = 1;
   		axi_tx_mon.rd_ready          	=        vif.rready;

  		axi_tx_mon.rd_id   		   		=	 	 vif.rid;   
		axi_tx_mon.rdata           		=        vif.rdata;
		axi_tx_mon.rd_resp           	=        vif.rresp;
		axi_tx_mon.rd_last           	=        vif.rlast;
    axi_config::read_request_q.push_back(axi_tx_mon);
    rd_req_num++;
		axi_tx_mon.rd_valid          	=        vif.rvalid;
  endtask
  
  task write_response_channel(axi_seq_item axi_tx_mon);
    
  		axi_tx_mon.bid 	= vif.bid;
		axi_tx_mon.bresp 	= vif.bresp;
		axi_tx_mon.bready 	= vif.bready;
		axi_tx_mon.bvalid 	= vif.bready;
    
  endtask

    task do_handshaking(axi_seq_item axi_tx_mon);
    	axi_tx_mon.wr_valid		=	vif.awvalid;
        axi_tx_mon.wr_ready		=	vif.awready;
        axi_tx_mon.rd_valid	=		vif.arvalid;
        axi_tx_mon.rd_ready	=		vif.arready;
        axi_tx_mon.bready 	= vif.bready;
        axi_tx_mon.bvalid 	= vif.bvalid;
    endtask

    
endclass