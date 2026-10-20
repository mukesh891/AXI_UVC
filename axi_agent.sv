class axi_agent extends uvm_agent;
  `NEW_COMP(axi_agent)
  
  axi_driver	axi_drv;
  axi_sequencer axi_sqr;
  axi_monitor axi_mon;
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    axi_drv = axi_driver::type_id::create("axi_drv",this);
    axi_sqr = axi_sequencer::type_id::create("axi_sqr",this);
    axi_mon = axi_monitor::type_id::create("axi_mon",this);
    
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
    axi_drv.seq_item_port.connect(axi_sqr.seq_item_export);
    
  endfunction
endclass