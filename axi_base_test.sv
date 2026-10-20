class axi_base_test extends uvm_test;
  
  `NEW_COMP(axi_base_test)
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_top.print_topology();
  endfunction
  
   
  
endclass

class axi_sample_test extends uvm_test;
  axi_environment axi_env;
  axi_sample_seq axi_seq;
  
  `NEW_COMP(axi_sample_test)
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    axi_seq = axi_sample_seq::type_id::create("axi_seq");
    axi_env = axi_environment::type_id::create("axi_env",this);
  endfunction
  
  task run_phase(uvm_phase phase);
    
    
    phase.raise_objection(this);
    axi_seq.start(axi_env.agent.axi_sqr);
    phase.phase_done.set_drain_time(this,1000);
    phase.drop_objection(this);
       uvm_top.print_topology();
  endtask
  
endclass

class axi_back_to_back_wr_rd_test extends axi_base_test;
  axi_environment axi_env;
  axi_back_to_back_wr_rd_seq axi_seq;
  
  function new(string name = "",uvm_component parent = null);
    super.new(name,parent);
  endfunction
  `uvm_component_utils(axi_back_to_back_wr_rd_test)
  
  //`NEW_COMP(axi_back_to_back_wr_rd_test)

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    axi_seq = axi_back_to_back_wr_rd_seq::type_id::create("axi_seq");
    axi_env = axi_environment::type_id::create("axi_env",this);
       uvm_top.print_topology();
  endfunction
  
  task run_phase(uvm_phase phase);
    
    
    phase.raise_objection(this);
    axi_seq.start(axi_env.agent.axi_sqr);
    phase.phase_done.set_drain_time(this,1000);
    phase.drop_objection(this);
       uvm_top.print_topology();
  endtask
  
endclass

class axi_preload_test extends axi_base_test;
  axi_environment axi_env;
  axi_preload_seq axi_pld_seq;
  
  /*function new(string name = "",uvm_component parent = null);
    super.new(name,parent);
  endfunction
  `uvm_component_utils(axi_preload_test)*/
  
  `NEW_COMP(axi_preload_test)

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    axi_pld_seq = axi_preload_seq::type_id::create("axi_pld_seq");
    axi_env = axi_environment::type_id::create("axi_env",this);
       uvm_top.print_topology();
  endfunction
  
  task run_phase(uvm_phase phase);
    
    
    phase.raise_objection(this);
    axi_pld_seq.start(axi_env.agent.axi_sqr);
    phase.phase_done.set_drain_time(this,1000);
    phase.drop_objection(this);
    uvm_top.print_topology();
  endtask
  
endclass