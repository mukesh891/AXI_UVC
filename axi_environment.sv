class axi_environment extends uvm_env;
  `NEW_COMP(axi_environment)
  
  axi_scoreboard scb;
  axi_agent agent;
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent = axi_agent::type_id::create("agent",this);
    scb = axi_scoreboard::type_id::create("scb",this);
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agent.axi_mon.mon_ap.connect(scb.scb_analysis_imp);
  endfunction
endclass