class axi_base_sequence extends uvm_sequence#(axi_seq_item);
    axi_config cfg;

  `NEW_OBJ(axi_base_sequence)
  `uvm_object_utils(axi_base_sequence)
  task pre_body();
    
    if(starting_phase!=null)begin
      starting_phase.raise_objection(this);
      starting_phase.phase_done.set_drain_time(this,1000);
      
    end
    cfg = new();
  endtask
  
  task post_body();

    if(starting_phase!=null)begin
      starting_phase.drop_objection(this);
    end
    
  endtask
endclass

class axi_sample_seq extends axi_base_sequence#(axi_seq_item);
  
  logic [63:0] addr_Q[$];
  logic [63:0] id_Q[$];
  logic [63:0] burst_Q[$];
  axi_seq_item axi_tx;
  `NEW_OBJ(axi_sample_seq)
  `uvm_object_utils(axi_sample_seq)
  
  task body();
    
    if(cfg.num_wr_tx<cfg.num_rd_tx)
      `uvm_fatal(get_full_name(),"num_rd_tx can't be greater than num_wr_tx, as in axi_sample_seq, we use Queue method to get the same Address and ID's for WRITE and READ")
    
    repeat(cfg.num_wr_tx)begin
      axi_tx = axi_seq_item::type_id::create("axi_tx");

      axi_tx.tx_type=WRITE;
      if(axi_tx.tx_type==WRITE)begin
        start_item(axi_tx);
      	write_addr_req();
        axi_config::tx_Q.push_back(axi_tx);
		//axi_tx.print();
        finish_item(axi_tx);
      end
    end
    repeat(cfg.num_rd_tx)begin
      axi_tx = axi_seq_item::type_id::create("axi_tx");

      axi_tx.tx_type=READ;
      if(axi_tx.tx_type==READ)begin
		start_item(axi_tx);
      	read_data_req();
        axi_config::tx_Q.push_back(axi_tx);
		//axi_tx.print();
        finish_item(axi_tx);
      end
    end
    axi_tx.tx_type=IDLE;
  endtask
  
  task write_addr_req();
    
    axi_tx.randomize() with{
      axi_tx.wr_valid == 1;
      axi_tx.wr_burst == 0;
      axi_tx.wr_size == 2;
      axi_tx.wr_len == 1;
      axi_tx.wr_strb == 3;
      axi_tx.wr_last == 1;
      axi_tx.bready == 1;
      //read signals
      
    };
    addr_Q.push_back(axi_tx.wr_addr);
    id_Q.push_back(axi_tx.wr_id);
    burst_Q.push_back(axi_tx.wr_burst);
    
  endtask
  
  task read_data_req();
    axi_tx.randomize() with{
      axi_tx.rd_valid == 1;
      axi_tx.rd_burst == 0;
      axi_tx.rd_ready == 1;
      axi_tx.rd_size == 2;
      axi_tx.rd_len == 1;
      

      //write signals
      axi_tx.wr_valid == 0;
      axi_tx.wr_burst == 0;
      axi_tx.wr_size == 0;
      axi_tx.wr_len == 0;
      axi_tx.wr_strb == 0;
    };
    axi_tx.rd_addr = addr_Q.pop_front();
    axi_tx.rd_id = id_Q.pop_front();
    axi_tx.rd_burst = burst_Q.pop_front();
  endtask
  
  
endclass

class axi_back_to_back_wr_rd_seq extends axi_base_sequence#(axi_seq_item);
  
  logic [63:0] addr_Q[$];
  logic [63:0] id_Q[$];
  logic [63:0] burst_Q[$];
  axi_seq_item axi_tx;
  axi_config cfg;

  //`NEW_OBJ(axi_back_to_back_wr_rd_seq)
  function new(string name=""); 
  	super.new(name);	
  	//`uvm_info(get_full_name(),$sformatf("Creating %0s Object",``name``),UVM_NONE)	
    cfg = new();
    
  endfunction	

  `uvm_object_utils(axi_back_to_back_wr_rd_seq)
  
  task body();
    
    if(cfg.num_wr_tx<cfg.num_rd_tx)
      `uvm_fatal(get_full_name(),"num_rd_tx can't be greater than num_wr_tx, as in axi_sample_seq, we use Queue method to get the same Address and ID's for WRITE and READ")
    
    repeat(cfg.num_wr_tx)begin
      axi_tx = axi_seq_item::type_id::create("axi_tx");

      axi_tx.tx_type=WRITE;
      if(axi_tx.tx_type==WRITE)begin
        start_item(axi_tx);
      	write_addr_req();
        axi_config::tx_Q.push_back(axi_tx);
		//axi_tx.print();
        finish_item(axi_tx);
      end
    end
    
    repeat(cfg.num_rd_tx)begin
      axi_tx = axi_seq_item::type_id::create("axi_tx");

      axi_tx.tx_type=READ;
      if(axi_tx.tx_type==READ)begin
		start_item(axi_tx);
      	read_data_req();
		//axi_tx.print();
        axi_config::tx_Q.push_back(axi_tx);

        finish_item(axi_tx);
      end
    end
    axi_tx.tx_type=IDLE;
  endtask
  
  task write_addr_req();
    
    axi_tx.randomize() with{
      axi_tx.wr_valid == 1;
      axi_tx.wr_burst == 1;
      axi_tx.wr_size == 2;
      axi_tx.wr_len == 1;
      axi_tx.wr_strb == 3;
      axi_tx.wr_last == 1;
      axi_tx.bready == 1;

      //read signals
      
    };
    addr_Q.push_back(axi_tx.wr_addr);
    id_Q.push_back(axi_tx.wr_id);
    burst_Q.push_back(axi_tx.wr_burst);
    
  endtask
  
  task read_data_req();
    axi_tx.randomize() with{
      axi_tx.rd_valid == 1;
      axi_tx.rd_burst == 1;
      axi_tx.rd_ready == 1;
      axi_tx.rd_size == 2;
      axi_tx.rd_len == 1;

      //write signals
      axi_tx.wr_valid == 0;
      axi_tx.wr_burst == 0;
      axi_tx.wr_size == 2;
      axi_tx.wr_len == 0;
      axi_tx.wr_strb == 0;
    };
    axi_tx.rd_addr = addr_Q.pop_front();
    axi_tx.rd_id = id_Q.pop_front();
    axi_tx.rd_burst = burst_Q.pop_front();
  endtask
  
  
endclass

class axi_preload_seq extends axi_base_sequence#(axi_seq_item);
  
  logic [63:0] addr_Q[$];
  logic [63:0] id_Q[$];
  logic [63:0] burst_Q[$];
  axi_seq_item axi_tx;
    int num_wr_tx=0,num_rd_tx=0;
  string num_wr_tx_str,num_rd_tx_str;
  uvm_cmdline_processor clp;
  axi_config cfg;

  //`NEW_OBJ(axi_back_to_back_wr_rd_seq)
  function new(string name=""); 
  	super.new(name);	
  	//`uvm_info(get_full_name(),$sformatf("Creating %0s Object",``name``),UVM_NONE)	
    cfg = new();
    
  endfunction	

  `uvm_object_utils(axi_preload_seq)
  
  task body();
    
    repeat(cfg.num_wr_tx)begin
      axi_tx = axi_seq_item::type_id::create("axi_tx");

      axi_tx.tx_type=WRITE;
      if(axi_tx.tx_type==WRITE)begin
        start_item(axi_tx);
      	write_addr_req();
        axi_config::tx_Q.push_back(axi_tx);
		//axi_tx.print();
        finish_item(axi_tx);
      end
    end
    
    repeat(cfg.num_rd_tx)begin
      axi_tx = axi_seq_item::type_id::create("axi_tx");

      axi_tx.tx_type=READ;
      if(axi_tx.tx_type==READ)begin
		start_item(axi_tx);
      	read_data_req();
		//axi_tx.print();
        axi_config::tx_Q.push_back(axi_tx);

        finish_item(axi_tx);
      end
    end
    axi_tx.tx_type=IDLE;
  endtask

  task write_addr_req();
    
    axi_tx.randomize() with{
      axi_tx.wr_valid == 1;
      axi_tx.wr_burst == 1;
      axi_tx.wr_size == 2;
      axi_tx.wr_len == 1;
      axi_tx.wr_strb == 3;
      axi_tx.wr_last == 1;
      axi_tx.bready == 1;

      //read signals
      
    };
    
    
  endtask
  
  task read_data_req();
    axi_tx.randomize() with{
      axi_tx.rd_valid == 1;
      axi_tx.rd_burst == 1;
      axi_tx.rd_ready == 1;
      axi_tx.rd_size == 2;
      axi_tx.rd_len == 1;

      //write signals
      axi_tx.wr_valid == 0;
      axi_tx.wr_burst == 0;
      axi_tx.wr_size == 2;
      axi_tx.wr_len == 0;
      axi_tx.wr_strb == 0;
    };
    
  endtask
  
  
endclass