`define LEN_BITS 4
`define SIZE_BITS 8
`define ID_BITS 4
`define ADDR_BITS 8
`define DATA_WIDTH 64

`define STROBE_SIZE 8
interface axi_interface(input clk,rst);
  //write addr signals
    logic 	[`ADDR_BITS-1:0]	awaddr;
  	logic 	[`LEN_BITS-1:0]		awlen;
  	logic 	[`SIZE_BITS-1:0]	awsize;
  	logic 	[`ID_BITS-1:0]		awid;//awid, wid, bid
  	logic 	[1:0]				awburst;
  	logic 	[1:0]				awlock;
  	logic 	[3:0]				awcache;
  	logic 	[2:0]				awprot;
	logic 						awvalid;
	logic  						awready;

  	logic 	[`ID_BITS-1:0]		wid;
  	logic 	[`DATA_WIDTH-1:0]	wdata;
    logic	[`STROBE_SIZE-1:0] 	wstrb;
	logic 						wlast;
	logic 						wvalid;
	logic  						wready;
 
        //write response signals
  	logic  [3:0]			bid;
    logic  [2:0]			bresp;
	logic  					bvalid;
	logic   				bready;

    //read addr signals	
    logic 	[`ADDR_BITS-1:0]	araddr;
  	logic 	[`LEN_BITS-1:0]		arlen;
  	logic 	[`SIZE_BITS-1:0]	arsize;
  	logic 	[`ID_BITS-1:0]		arid;  //awid, wid, bid
  	logic 	[1:0]				arburst;
  	logic 	[1:0]				arlock;
  	logic 	[1:0]				arcache;
  	logic 	[1:0]				arprot;

	logic 						arvalid;
	logic  						arready;

	//read data signals
  	logic  [`ID_BITS-1:0] 	rid;
  	logic  [`DATA_WIDTH-1:0]rdata;
    logic   [2:0]			rresp;
	logic  					rlast;
	logic  					rvalid;
	logic 					rready;
  
  clocking driver_cb@(posedge clk);
    //write addr signals
    output 						awaddr;
  	output 						awlen;
  	output 						awsize;
  	output 						awid;//awid, wid, bid
  	//output 						awresp;
  	output 						awburst;
  	output 						awlock;
  	output 						awcache;
  	output 						awprot;
	output 						awvalid;
	input  						awready;

  	output 						wid;
  	output 						wdata;
    output						wstrb;
	output 						wlast;
	output 						wvalid;
	input  						wready;
 
        //write response signals
  	input  					bid;
    input        			bresp;
	input  					bvalid;
	output   				bready;

    //read addr signals	
    output 			araddr;
  	output 			arlen;
  	output 			arsize;
  	output 			arid;  //awid, wid, bid
  	output 					arburst;
  	output 					arlock;
  	output 					arcache;
  	output 					arprot;

	output 						arvalid;
	input  						arready;

	//read data signals
  	input   				rid;
  	input  					rdata;
  	input   				rresp;
	input  					rlast;
	input  					rvalid;
	output 					rready;
  
  endclocking
  
    clocking monitor_cb@(posedge clk);
    //write addr signals
    input 						awaddr;
  	input 						awlen;
  	input 						awsize;
  	input 						awid;//awid, wid, bid
  	//input 						awresp;
  	input 						awburst;
  	input 						awlock;
  	input 						awcache;
  	input 						awprot;
	input 						awvalid;
	input  						awready;

  	input 						wid;
  	input 						wdata;
    input						wstrb;
	input 						wlast;
	input 						wvalid;
	input  						wready;
 
        //write response signals
  	input  					bid;
	input  					bresp;
	input  					bvalid;
	input   				bready;

    //read addr signals	
    input 			araddr;
  	input 			arlen;
  	input 			arsize;
  	input 			arid;  //awid, wid, bid
  	input 					arburst;
  	input 					arlock;
  	input 					arcache;
  	input 					arprot;

	input 						arvalid;
	input  						arready;

	//read data signals
  	input   				rid;
  	input  					rdata;
  	input   				rresp;
	input  					rlast;
	input  					rvalid;
	input 					rready;
  
  endclocking
endinterface
