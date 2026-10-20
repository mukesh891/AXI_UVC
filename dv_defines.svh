`define LEN_BITS 4
`define SIZE_BITS 8
`define ID_BITS 4
`define ADDR_BITS 8
`define DATA_WIDTH 64

`define STROBE_SIZE 8


package axi_dv_pkg;
/*
typedef struct packed{
	logic valid;
	logic   [`ADDR_BITS-1:0] 	awaddr;
	logic   [`LEN_BITS-1:0] 	awlen;
  	logic   [`SIZE_BITS-1:0] 	awsize;
    logic   [`ID_BITS-1:0] 		awid;  		//awid, wid, bid
    //logic   [`DATA_WIDTH-1:0]	wdataQ[$];
    //logic   [7:0] 				awstrbQ[$];
    logic   [1:0] 				awresp;
    logic   [1:0] 				awburst;
    logic   [1:0] 				awlock;
    logic   [3:0] 				awcache;
    logic   [2:0] 				awprot;
    logic						awvalid;
    logic 						awready;
} addr_write_req;

typedef struct{
	logic   [`ADDR_BITS-1:0] 	araddr;
    //logic   [`DATA_WIDTH-1:0]	rdataQ[$];
    logic   [`LEN_BITS-1:0] 	arlen;
  	logic   [`SIZE_BITS-1:0] 	arsize;
    logic   [`ID_BITS-1:0] 		arid;  //awid, wid, bid
    logic   [1:0] 				arburst;
    logic   [1:0] 				arlock;
    logic   [1:0] 				arcache;
    logic   [1:0] 				arprot;

    logic 						arvalid;
    logic 						arready;
} addr_read_req;
*/
endpackage