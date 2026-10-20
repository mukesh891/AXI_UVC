typedef enum bit[2:0]{
  IDLE,
  READ,
  WRITE,
  READ_RESP,
  WRITE_RESP
} transaction_type;

typedef byte  mem_t [2**`SIZE_BITS];

class axi_seq_item extends uvm_sequence_item;
  //`NEW_OBJ(axi_seq_item)
  function new(string name="");
    super.new(name);
  endfunction
    //write addr signals
  	rand logic 	[`ADDR_BITS-1:0]	wr_addr;
  	rand logic 	[`LEN_BITS-1:0]		wr_len;
  	rand logic 	[`SIZE_BITS-1:0]	wr_size;
  	rand logic 	[`ID_BITS-1:0]		wr_id;//awid, wid, bid
  	//rand logic 	[1:0]				wr_resp;
  	rand logic 	[1:0]				wr_burst;
  	rand logic 	[1:0]				wr_lock;
  	rand logic 	[3:0]				wr_cache;
  	rand logic 	[2:0]				wr_prot;
	rand logic 						wr_valid;
	logic  							wr_ready;

  	//rand logic 	[`ID_BITS-1:0]		wid;
  	rand logic 	[`DATA_WIDTH-1:0]	wdata;
  	rand logic	[`STROBE_SIZE-1:0] 	wr_strb;
  	rand logic 						wr_last;
	//rand logic 						wvalid;
	//logic  						wready;
 
        //write response signals
  	logic  [3:0]			bid;
    logic  [2:0]			bresp;
	logic  					bvalid;
	rand logic   				bready;

    //read addr signals	
  rand logic 	[`ADDR_BITS-1:0]	rd_addr;
  	rand logic 	[`LEN_BITS-1:0]		rd_len;
  	rand logic 	[`SIZE_BITS-1:0]	rd_size;
  	rand logic 	[`ID_BITS-1:0]		rd_id;  //awid, wid, bid
  	rand logic 	[1:0]				rd_burst;
  	rand logic 	[1:0]				rd_lock;
  	rand logic 	[1:0]				rd_cache;
  	rand logic 	[1:0]				rd_prot;

	rand logic 						rd_valid;
	rand logic  					rd_ready;

	//read data signals
  //logic  [`ID_BITS-1:0] 	rd_id;
  	logic  [`DATA_WIDTH-1:0]rdata;
    logic   [2:0]			rd_resp;
	logic  					rd_last;
	//logic  					rd_valid;
	//rand logic 					rd_ready;
  
  transaction_type tx_type;
  
  `uvm_object_utils_begin(axi_seq_item)
  
`uvm_field_int(wr_addr,UVM_ALL_ON)
`uvm_field_int(wr_len,UVM_ALL_ON)
`uvm_field_int(wr_size,UVM_ALL_ON)
`uvm_field_int(wr_id,UVM_ALL_ON)  //awid, wid, bid

//`uvm_field_int(wr_resp,UVM_ALL_ON)
`uvm_field_int(wr_burst,UVM_ALL_ON)
`uvm_field_int(wr_lock,UVM_ALL_ON)
`uvm_field_int(wr_cache,UVM_ALL_ON)
`uvm_field_int(wr_prot,UVM_ALL_ON)
`uvm_field_int(wr_valid,UVM_ALL_ON)
`uvm_field_int(wr_ready,UVM_ALL_ON)

//`uvm_field_int(wid,UVM_ALL_ON)
`uvm_field_int(wdata,UVM_ALL_ON)
  `uvm_field_int(wr_strb,UVM_ALL_ON)
  `uvm_field_int(wr_last,UVM_ALL_ON)
//`uvm_field_int(wvalid,UVM_ALL_ON)
//`uvm_field_int(wready,UVM_ALL_ON)

//write response signals

  `uvm_field_int(bid,UVM_ALL_ON)
`uvm_field_int(bresp,UVM_ALL_ON)
`uvm_field_int(bvalid,UVM_ALL_ON)
`uvm_field_int(bready,UVM_ALL_ON)

//read addr signals	
`uvm_field_int(rd_addr,UVM_ALL_ON)
`uvm_field_int(rd_len,UVM_ALL_ON)
`uvm_field_int(rd_size,UVM_ALL_ON)
`uvm_field_int(rd_id,UVM_ALL_ON)  //awid, wid, bid
`uvm_field_int(rd_burst,UVM_ALL_ON)
`uvm_field_int(rd_lock,UVM_ALL_ON)
`uvm_field_int(rd_cache,UVM_ALL_ON)
`uvm_field_int(rd_prot,UVM_ALL_ON)

`uvm_field_int(rd_valid,UVM_ALL_ON)
`uvm_field_int(rd_ready,UVM_ALL_ON)

//read data signals
`uvm_field_int(rdata,UVM_ALL_ON)
  `uvm_field_int(rd_resp,UVM_ALL_ON)
  `uvm_field_int(rd_last,UVM_ALL_ON)
  `uvm_field_enum(transaction_type, tx_type, UVM_ALL_ON)
//`uvm_field_int(rvalid,UVM_ALL_ON)
//`uvm_field_int(rready,UVM_ALL_ON)
  
  `uvm_object_utils_end
  
  function void print();
    	if (tx_type == WRITE) begin
    $display("\n--- Write Transaction ---");
        $display("Write Valid      = 0x%0h", wr_valid);
        $display("Write Ready      = 0x%0h", wr_ready);
    	$display("Write Address      = 0x%0h", wr_addr);
    	$display("Write Data      = 0x%0h", wdata);
    	$display("Write Length       = 0x%0h (%0d)", wr_len, wr_len);
    	$display("Write Size         = 0x%0h (%0d bytes)", wr_size, 1 << wr_size); // size = log2(bytes)
    	$display("Write ID           = 0x%0h", wr_id);
    	$display("Write Burst        = 0x%0h", wr_burst);
    	$display("Write Lock         = 0x%0h", wr_lock);
    	$display("Write Cache        = 0x%0h", wr_cache);
    	$display("Write Protection   = 0x%0h", wr_prot);
        $display("Write Response     = 0x%0h", bresp);
    	$display("Write Strobe     = 0x%0h", wr_strb);
        $display("Write last     = 0x%0h", wr_last);
    
    // Display write data queue
    /*foreach (wdataQ[i]) begin
        $display("WData[%0d]          = 0x%016h", i, wdataQ[i]);
    end

    // Display write strobe queue
    foreach (wr_strbQ[i]) begin
        $display("WStrb[%0d]          = 0x%02h", i, wr_strbQ[i]);
    end*/
    $display("--- End Write Transaction ---\n");
    end
    if (tx_type == READ) begin
    	$display("\n--- Read Transaction ---");
      	$display("Read Valid       = 0x%0h", rd_valid);
    	$display("Read Address       = 0x%0h", rd_addr);
    	$display("Read Data      = 0x%0h", rdata);
    	$display("Read Length        = 0x%0h (%0d)", rd_len, rd_len);
    	$display("Read Size          = 0x%0h (%0d bytes)", rd_size, 1 << rd_size); // AXI size = log2(bytes)
    	$display("Read ID            = 0x%0h", rd_id);
    	$display("Read Burst         = 0x%0h", rd_burst);
    	$display("Read Lock          = 0x%0h", rd_lock);
    	$display("Read Cache         = 0x%0h", rd_cache);
    	$display("Read Protection    = 0x%0h", rd_prot);

    // Display read data queue
    /*foreach (rdataQ[i]) begin
        $display("RData[%0d]          = 0x%016h", i, rdataQ[i]);
    end*/
    $display("--- End Read Transaction ---\n");
    end
    
  //endfunction
  
    //function void print_write_response();
      if (tx_type == WRITE_RESP) begin

      $display("\n--- Write Request Transaction   ---");
      $display("Response BVALID       = 0x%0h", bvalid);
      $display("Response BREADY       = 0x%0h", bready);
      $display("Response BID       	 = 0x%0h", bid);
      $display("Response BRESP       = 0x%0h", bresp);
      
      
      $display("--- End Write Response Transaction ---\n");
      end
    //endfunction
  
  //function void print_read_response();
    if (tx_type == READ_RESP) begin
    $display("\n--- Read Request Transaction   ---");
    $display("Response RVALID       = 0x%0h", rd_valid);
    $display("Response RREADY       = 0x%0h", rd_ready);
    $display("Response RID          = 0x%0h", rd_id);
    $display("Response RRESP        = 0x%0h", rd_resp);
      
      
      $display("--- End Read Response Transaction ---\n");
    end
    endfunction
  
  
endclass