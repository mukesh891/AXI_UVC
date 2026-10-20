`define NEW_OBJ(name) \
function new(string ``name``=""); \
  super.new(``name``);	\
  `uvm_info(get_full_name(),$sformatf("Creating %0s Object",``name``),UVM_NONE)	\
endfunction	

`define NEW_COMP(name) \
function new(string ``name``="", uvm_component parent = null); \
  super.new(``name``,parent);	\
  `uvm_info(get_full_name(),$sformatf("Creating %0s Component",``name``),UVM_NONE)	\
endfunction \
`uvm_component_utils(``name``)

class axi_config extends uvm_object;
  `uvm_object_utils(axi_config)
  
  int num_wr_tx=0,num_rd_tx=0;
  string num_wr_tx_str,num_rd_tx_str;
  uvm_cmdline_processor clp;
  
  function new(string name=""); 
  super.new(name);
  //`uvm_info(get_full_name(),$sformatf("Creating %0s Object",name),UVM_NONE)	
    clp = uvm_cmdline_processor::get_inst();
    if(clp.get_arg_value("+num_wr_tx=", num_wr_tx_str))
      $sscanf(num_wr_tx_str,"%0h",num_wr_tx);
    if(clp.get_arg_value("+num_rd_tx=", num_rd_tx_str))
      $sscanf(num_rd_tx_str,"%0h",num_rd_tx);
endfunction	
  
  static axi_seq_item tx_Q[$];
  static axi_seq_item write_request_q[$];
  static axi_seq_item read_request_q[$];
  static int num_gen_wr_req=0,num_resp2wr_req=0,num_gen_rd_req=0,num_resp2rd_req=0;
endclass