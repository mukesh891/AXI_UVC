class axi_sequencer extends uvm_sequencer#(axi_seq_item);
  `NEW_COMP(axi_sequencer)
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
endclass