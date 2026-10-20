class axi_scoreboard extends uvm_scoreboard;
  `NEW_COMP(axi_scoreboard)
  axi_config 			cfg;
  //write_response_t write_response ;
  virtual axi_interface vif;
  axi_seq_item axi_tx_q[$],wr_tx,rd_tx,axi_wr_req_Q[$],read_rresp_Q[$],wr_n_resp_comp_Q[$],rd_n_resp_comp_Q[$],wr_resp_pending_tx,rd_resp_pending_tx,write_bresp_Q[$];
  uvm_analysis_imp#(axi_seq_item,axi_scoreboard) scb_analysis_imp;
  
  axi_seq_item new_tx;
  //byte ref_mem [2**`SIZE_BITS];
  mem_t ref_mem;
  
  logic[63:0] ref_rdata;
  
  int total_byte_size,wrap_boundary,wr_resp_flag_match,rd_resp_flag_match,rd_wait_q_num[32],wr_wait_q_num[32],rd_index_match,wr_index_match
  ,wr_resp_cnt=0,rd_resp_cnt=0;
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    scb_analysis_imp = new("scb_analysis_imp",this);
    
    rd_tx = axi_seq_item::type_id::create("rd_tx");
    
    if(!uvm_resource_db#(virtual axi_interface)::read_by_name("TOP","pif",vif,null))
      `uvm_fatal(get_full_name(),"VIF is not configured properly")
      
      cfg = new();
    
    uvm_config_db#(mem_t)::get(this,"","preload_mem",ref_mem);

  endfunction
  
  
  
  function write(axi_seq_item axi_tx);
    //**************************************//
    //   Getting VIF values from MONITOR	//
    //**************************************//
    if(vif.bresp==0)begin
      	write_bresp_Q.push_back(axi_tx);
      	/*
        $display("**************** %0t WRITE RESPONSE Q START  ****************",$time);
      	axi_tx.print();
     	$display("**************** %0t WRITE RESPONSE Q START  ****************",$time);
		*/
    end
    axi_tx_q.push_back(axi_tx);
      
    if(axi_tx.wr_valid && axi_tx.wr_ready && axi_tx.wr_last)begin
      axi_wr_req_Q.push_back(axi_tx);
      /*
      $display("**************** %0t WRITE REQ Q START  ****************",$time);
      axi_tx.print();
      $display("****************   %0t WRITE REQ Q END  ****************",$time);
	  */
    end
    if(vif.rresp==0)begin
        read_rresp_Q.push_back(axi_tx);
        /*
        $display("**************** %0t READ REQ Q START  ****************",$time);
        axi_tx.print();
        $display("****************   %0t READ REQ Q END  ****************",$time);
        */
      end
  endfunction
  
  task run_phase(uvm_phase phase);
    foreach(wr_wait_q_num[i])
      wr_wait_q_num[i]=0;
    foreach(rd_wait_q_num[i])
      rd_wait_q_num[i]=0;
    
    wait(vif.rst==0);
    forever begin
      @(posedge vif.clk);
      wr_resp_flag_match = 0;
      rd_resp_flag_match = 0;

      wr_n_resp_comp_Q = write_bresp_Q;
      
      //**************************************//
      //  Write Address & Data Request Start  //
      //**************************************//
      if(axi_wr_req_Q.size()>0)begin
        wr_tx = axi_seq_item::type_id::create("wr_tx");
        wr_tx = axi_wr_req_Q.pop_front();
        wr_tx.tx_type=WRITE;
        //wr_tx.print();
        if(wr_tx.wr_last)begin
    	  total_byte_size <= 2**(wr_tx.wr_size) *(wr_tx.wr_len);
        case(wr_tx.wr_burst)
    	0 : begin
          	for(int i=0; i<wr_tx.wr_len; i++)begin
              for(int ii=0; ii<2**(wr_tx.wr_size); ii++)begin
                if(wr_tx.wr_strb[ii])begin
                  ref_mem[wr_tx.wr_addr+ii] 	<= wr_tx.wdata[8*ii +: 8];
                      /*$display("------------FIXED TYPE------------");
                  	  $display("--------Wdata = %h wr_addr= %0h, strb = %0b-----------",wr_tx.wdata,wr_tx.wr_addr,wr_tx.wr_strb);
                      $display("--------Write to ref_mem[%h] = %h -----------",wr_tx.wr_addr+ii,ref_mem[wr_tx.wr_addr+ii]);
                      */
    				end
    			end
    		end
        end
      	1 : begin
        	for(int i=0; i<wr_tx.wr_len; i++)begin
              for(int ii=0; ii<2**(wr_tx.wr_size); ii++)begin
                if(wr_tx.wr_strb[ii])begin
                  ref_mem[wr_tx.wr_addr+ii] 	<= wr_tx.wdata[8*ii +: 8];
                  /*
                  $display("------------INCR TYPE------------");

                  $display("--------Wdata = %h wr_addr= %0h, strb = %0b-----------",wr_tx.wdata,wr_tx.wr_addr,wr_tx.wr_strb);
                        
                  $display("--------Write to ref_mem[%h] = %h -----------",wr_tx.wr_addr+ii,ref_mem[wr_tx.wr_addr+ii]);
                  */
    			end
    		  end
              	// INCREMENT ADDR by 8
              	// TODO : Make it generic
              wr_tx.wr_addr <= wr_tx.wr_addr +`STROBE_SIZE;
    		end
        end
      	2 : begin
       		//$display("------------WRAP TYPE------------");
			wrap_boundary <= (wr_tx.wr_addr / total_byte_size) * total_byte_size;
            //$display("wrap_boundary = %0h", wrap_boundary);
          for(int i=0; i<wr_tx.wr_len; i++)begin
            for(int ii=0; ii<2**(wr_tx.wr_size); ii++)begin
                if(wr_tx.wr_addr+ii >= wrap_boundary+total_byte_size)
                      wr_tx.wr_addr<= wr_tx.wr_addr - wrap_boundary;
              if(wr_tx.wr_strb[ii])begin
                  	ref_mem[wr_tx.wr_addr+ii] 	<= wr_tx.wdata[8*ii +: 8];
                	//$display("--------Wdata = %h wr_addr= %0h, strb = %0b-----------",wr_tx.wdata,wr_tx.wr_addr,wr_tx.wr_strb);
                  	//$display("--------Write to ref_mem[%h] = %h -----------",wr_tx.wr_addr+ii,ref_mem[wr_tx.wr_addr+ii]);
    				end
                
    			end
    		end
        end
    endcase
	
          //ref_mem[wr_tx.wr_addr] = wdata;
    end// if(wr_tx.wr_valid && wr_tx.wr_ready)
    end// if(axi_wr_req_Q.size>0)
      
      //**************************************//
      //  Write Address & Data Request End    //
      //**************************************//
      
      
      //**************************************//
      //     Write Response Check Start 	  //
      //**************************************//
       
      if(axi_config::write_request_q.size()>0 && write_bresp_Q.size()>0)begin
         
	  for (int i = write_bresp_Q.size()-1; i >= 0; i--) begin
        
        for (int j = axi_config::write_request_q.size()-1; j >= 0; j--) begin        
          if ((axi_config::write_request_q[j].wr_id == write_bresp_Q[i].bid) &&
        	write_bresp_Q[i].bvalid &&
        	write_bresp_Q[i].bready &&
        	(write_bresp_Q[i].bresp == 0)) begin

          	wr_resp_flag_match = 1;
            wr_index_match = 1;
        
            if(wr_resp_flag_match)begin
            	`uvm_info(get_full_name(),$sformatf("\tGOT WRITE RESPONSE : SUCCESSFULLY RECIEVED WRITE RESPONSE FROM DUT FOR ID : %0h",axi_config::write_request_q[j].wr_id),UVM_NONE)
            	wr_resp_flag_match = 0;
            	wr_resp_cnt++;

          	end
          
          	if(wr_index_match==1)begin
              	`uvm_info(get_full_name(),$sformatf("\tDELETING WRITE REQUEST : SUCCESSFULLY DELETED WRITE REQUEST  FROM write_bresp_Q FOR ID : %0h",axi_config::write_request_q[j].wr_id),UVM_NONE)
              	write_bresp_Q.delete(i);
            	axi_config::write_request_q.delete(j);
              	wr_wait_q_num[i]=0;
              	wr_index_match=0;
          	end// if(index_match==i)
          end // if((axi_config::write_response[j].bid == write_bresp_Q[i].bid) && ...
		
          else begin
            wr_resp_pending_tx = axi_config::write_request_q[j];
            if(wr_resp_pending_tx.wr_id!=null)begin
          		`uvm_info(get_full_name(),$sformatf("WAITING FOR WRITE RESPONSE FOR TX : "),UVM_NONE)
        		//wr_resp_tx.print_write_response();
        		wr_wait_q_num[i]++;
             
          	end
          end
          
        end// foreach(axi_config::write_response[i])
      end// foreach(wr_n_resp_comp_Q[i]))
      end // if(axi_config::write_request_q.size()>0
            
      
      //**************************************//
      //       Write Response Check End 	  //
      //**************************************//
      
      //**************************************//
      //  Read Data and Response Check Start  //
      //**************************************//
	/*
      foreach(axi_config::read_request_q[i])
        $display("axi_config::read_request_q[%0d] = %0p ",i,axi_config::read_request_q[i]);
      foreach(write_bresp_Q[i])
        $display("read_rresp_Q[%0d] = %0p ",i,read_rresp_Q[i]);
      */
      if(axi_config::read_request_q.size()>0 && read_rresp_Q.size()>0)begin
         
	  for (int i = read_rresp_Q.size()-1; i >= 0; i--) begin
        
        for (int j = axi_config::read_request_q.size()-1; j >= 0; j--) begin        
          if ((axi_config::read_request_q[j].rd_id == read_rresp_Q[i].rd_id) &&
              (read_rresp_Q[i].rd_resp == 0) &&
              (read_rresp_Q[i].rd_last==1)) begin

          	rd_resp_flag_match = 1;
            rd_index_match = 1;
        
            if(rd_resp_flag_match)begin
              `uvm_info(get_full_name(),$sformatf("\tGOT READ RESPONSE : SUCCESSFULLY RECIEVED READ RESPONSE FROM DUT FOR ID : %0h",axi_config::read_request_q[j].rd_id),UVM_NONE)
            	rd_resp_flag_match = 0;
            	rd_resp_cnt++;
            
              for(int ii=0;ii < axi_config::read_request_q[j].rd_len;ii++)begin
                for(int jj=0;jj < `STROBE_SIZE;jj++)begin
		 	//storing the recieved values.    
                  ref_rdata[8*jj +: 8] =  	ref_mem[axi_config::read_request_q[j].rd_addr+jj];
			//rid<=arid;
                end
            end

            if(ref_rdata == read_rresp_Q[i].rdata)begin
              
          		`uvm_info(get_full_name(),$sformatf("DATA MATCH SUCCESSFUL for ID: 0x%0h\n\t MEMORY REFERENCE DATA : \t%0h	\n\t ACTUAL DATA FROM DUT  : \t%0h",axi_config::read_request_q[j].rd_id, ref_rdata, read_rresp_Q[i].rdata),UVM_NONE)
              
        end// if(ref_rdata == read_rresp_Q[i].rdata)
          	end
           
          
            if(rd_index_match==1)begin
              `uvm_info(get_full_name(),$sformatf("\tDELETING READ REQUEST : SUCCESSFULLY DELETED READ REQUEST  FROM read_rresp_Q FOR ID : %0h",axi_config::read_request_q[j].rd_id),UVM_NONE)
              	read_rresp_Q.delete(i);
            	axi_config::read_request_q.delete(j);
              	rd_wait_q_num[i]=0;
              	rd_index_match=0;
          	end// if(index_match==i)
          end // if((axi_config::write_response[j].bid == write_bresp_Q[i].bid) && ...
		
          else begin
            rd_resp_pending_tx = axi_config::read_request_q[j];
            if(rd_resp_pending_tx.rd_id!=null)begin
              `uvm_info(get_full_name(),$sformatf("WAITING FOR READ RESPONSE FOR TX : "),UVM_NONE)
                rd_resp_pending_tx.tx_type=READ_RESP;
        		rd_resp_pending_tx.print();
        		rd_wait_q_num[i]++;
                $display("**************** %0t 10 SCOREBOARD DISPLAY  ****************",$time);
               
          	end
          end
          
        end// foreach(axi_config::write_response[i])
      end// foreach(wr_n_resp_comp_Q[i]))
      end // if(axi_config::write_request_q.size()>0
         
            
      //**************************************//
      //  Read Data and Response Check End    //
      //**************************************//
      
      
    end// forever begin
  endtask
  
  function void report_phase(uvm_phase phase);
  	super.report_phase(phase);
	`uvm_info(get_full_name(),$sformatf("\n Total number of Write TX Done  : \t%0h \n Total number of Write Response Recieved  : \t%0h \n Total number of Read TX Done  : \t%0h \n Total number of Read Response Recieved  : \t%0h",cfg.num_wr_tx,wr_resp_cnt,cfg.num_rd_tx,rd_resp_cnt),UVM_NONE)
  endfunction
endclass





