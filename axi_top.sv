module axi_top;
  
  bit clk,rst;
  axi_interface pif(clk,rst);
  string test_name,preload_str;
  uvm_cmdline_processor clp;
  byte rand_data;
  bit preload;
  mem_t preload_mem;
  
//    	always #5 clk = ~clk;

  initial begin
    clk = 0;
  	forever #5 clk = ~clk;
  end
  
  initial begin
  	rst = 1;
    repeat(2)@(posedge clk );
    rst = 0;
  end
  
  initial begin
    uvm_resource_db#(virtual axi_interface)::set("TOP","pif",pif,null);
    clp = uvm_cmdline_processor::get_inst();
    
    //***********************************************//
    // 	  PRELOADING DATA TO DUT MEMORY START        //
    //***********************************************//
    
    //Enabled preload by default
    for(int i=0;i<2**`SIZE_BITS;i++)begin
        rand_data = $urandom;
        //$display("################# PRELOAD DATA ENABLED #################");
        //$display("#################   DATA = %0h #################",rand_data);
        dut_0.mem[i] = rand_data;
        preload_mem[i] = rand_data;
    end
    
    // CODE FOR : PRELOAD enable from command line  
    /*
    if(clp.get_arg_value("+preload=", preload_str))
      $sscanf(preload_str,"%0b",preload);
    if(preload)begin
      for(int i=0;i<2**`SIZE_BITS;i++)begin
        rand_data = $urandom;
        //$display("################# PRELOAD DATA ENABLED #################");
        //$display("#################   DATA = %0h #################",rand_data);
        dut_0.mem[i] = rand_data;
        preload_mem[i] = rand_data;
      end
    end
    */
    
    uvm_config_db#(mem_t)::set(null,"*","preload_mem",preload_mem);
      
    //***********************************************//
    // 	   PRELOADING DATA TO DUT MEMORY END         //
    //***********************************************//
      
    /*
    if(clp.get_arg_value("+test_name=", test_name))begin
      $display("############# Running Test - %0s #############",test_name);
    	run_test(test_name);
    end
    else	run_test("axi_sample_test");
    */
    
    run_test("axi_sample_test");
    
  end
  
  initial begin
  	#90000;
    $finish;
  end
  
  axi_slave dut_0(
    .aclk(clk),
    .areset(rst),

.awaddr  (pif.awaddr),
.awlen   (pif.awlen),
.awsize  (pif.awsize),
.awid    (pif.awid ),

//.awresp		(pif.awresp),
.awburst        (pif.awburst),
.awlock         (pif.awlock),
.awcache        (pif.awcache),
.awprot         (pif.awprot),
.awvalid        (pif.awvalid),
.awready        (pif.awready),
              
.wid            (pif.wid),
.wdata          (pif.wdata),
.wstrb          (pif.wstrb),
.wlast          (pif.wlast),
.wvalid         (pif.wvalid),
.wready         (pif.wready),
             
.bid            (pif.bid),
.bresp          (pif.bresp),
.bvalid         (pif.bvalid),
.bready         (pif.bready),
             
.araddr         (pif.araddr),
.arlen          (pif.arlen),
.arsize         (pif.arsize),
.arid           (pif.arid),
.arburst        (pif.arburst),
.arlock         (pif.arlock),
.arcache        (pif.arcache),
.arprot         (pif.arprot),
                
.arvalid        (pif.arvalid),
.arready        (pif.arready),
              
.rid            (pif.rid),
.rdata          (pif.rdata),
.rresp          (pif.rresp),
.rlast          (pif.rlast),
.rvalid         (pif.rvalid),
.rready          (pif.rready)
  );
  
  initial begin
    $dumpvars();
    $dumpfile("axi_top.vcd");
  end
    
endmodule