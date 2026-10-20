// Code your design here
// Code your design here
`include "rtl_defines.svh"
module axi_slave(aclk,areset,
	//write addr signals
awaddr,
awlen,
awsize,
awid,  //awid, wid, bid

awburst,
awlock,
awcache,
awprot,
awvalid,
awready,

wid,
wdata,
wstrb,
wlast,
wvalid,
wready,
 
        //write response signals
bid,
bresp,
bvalid,
bready,

    //read addr signals	
araddr,
arlen,
arsize,
arid,  //awid, wid, bid
arburst,
arlock,
arcache,
arprot,

arvalid,
arready,

//read data signals
rid,
rdata,
rresp,
rlast,
rvalid,
rready);


	input aclk,areset;
	//write addr signals
    input 	[`ADDR_BITS-1:0]	awaddr;
  	input 	[`LEN_BITS-1:0]		awlen;
  	input 	[`SIZE_BITS-1:0]	awsize;
  	input 	[`ID_BITS-1:0]		awid;//awid, wid, bid
  	input 	[1:0]				awburst;
  	input 	[1:0]				awlock;
  	input 	[3:0]				awcache;
  	input 	[2:0]				awprot;
	input 						awvalid;
	output reg 					awready;

  	input 	[`ID_BITS-1:0]		wid;
  	input 	[`DATA_WIDTH-1:0]	wdata;
    input	[`STROBE_SIZE-1:0] 	wstrb;
	input 						wlast;
	input 						wvalid;
	output reg 					wready;
 
        //write response signals
  	output reg [3:0]			bid;
    output reg [2:0]			bresp;
	output reg 					bvalid;
	input  reg 					bready;

    //read addr signals	
    input 	[`ADDR_BITS-1:0]	araddr;
  	input 	[`LEN_BITS-1:0]		arlen;
  	input 	[`SIZE_BITS-1:0]	arsize;
  	input 	[`ID_BITS-1:0]		arid;  //awid, wid, bid
  	input 	[1:0]				arburst;
  	input 	[1:0]				arlock;
  	input 	[1:0]				arcache;
  	input 	[1:0]				arprot;

	input 						arvalid;
	output reg 					arready;

	//read data signals
  	output reg [`ID_BITS-1:0] 	rid;
  	output reg [`DATA_WIDTH-1:0]rdata;
    output reg  [2:0]			rresp;
	output reg 					rlast;
	output reg 					rvalid;
	input 						rready;
  
  byte mem [2**`SIZE_BITS];//rresp
	//temp reg to store conrol information
  reg [`ADDR_BITS-1:0] temp_addr;
  reg temp_valid;
  reg temp_ready;
		//storing the recieved values.
  reg [`ID_BITS-1:0] temp_id;
  reg [`LEN_BITS-1:0] temp_len;
  reg [`SIZE_BITS-1:0] temp_size ;
  reg[1:0] temp_burst;
  
  reg [`ADDR_BITS-1:0] temp_rd_addr;
  reg temp_rd_valid;
  reg temp_rd_ready;
		//storing the recieved values.
  reg [`ID_BITS-1:0] temp_rd_id;
  reg [`LEN_BITS-1:0] temp_rd_len;
  reg [`SIZE_BITS-1:0] temp_rd_size ;
  reg[1:0] temp_rd_burst;
bit [31:0] awaddr_t_arr[16];
bit [31:0] awlen_t_arr[16];
bit [31:0] awsize_t_arr[16];
bit [31:0] awburst_t_arr[16];

bit [31:0] araddr_t_arr[16];
bit [31:0] arlen_t_arr[16];
bit [31:0] arsize_t_arr[16];
bit [31:0] arburst_t_arr[16];
bit bready_f;
bit [`ID_BITS-1:0] rid_t;
  bit	[11:0]		   total_byte_size,wrap_boundary;			
  axi_pkg::addr_write_req axi_wr_req_q[16];
  axi_pkg::addr_read_req  axi_rd_req_q[16];
  reg [`DATA_WIDTH-1:0]rdata_temp;
  bit aw_done;
  
initial begin
  $display("////////////////////////axi_slave model////////////////////////");
end

always@(posedge aclk)begin
  	if(areset)begin
      rlast<=0;
      awready <= 0;
      wready <= 0;
      bvalid <= 0;
      arready <= 0;
      rvalid <= 1'b0;
      bresp='b111; // default value to determine IDLE response
      rresp='b111;
      for(int i = 0; i<2**`ID_BITS ; i++)begin
        axi_wr_req_q[i].awvalid<=1'b0;
      end
    end
	else begin
      bresp<='b111; // default value to determine IDLE response
      rresp<='b111;
      
      if (awvalid)begin
        awready<=1;
        axi_wr_req_q[awid].awvalid	<=	1;
        axi_wr_req_q[awid].awready	<=	1;
		//storing the recieved values.
        axi_wr_req_q[awid].awaddr 	<= 	awaddr;
        axi_wr_req_q[awid].awid 	<= 	awid;
        axi_wr_req_q[awid].awlen 	<= 	awlen;
        axi_wr_req_q[awid].awsize 	<= 	awsize;
        axi_wr_req_q[awid].awburst 	<= 	awburst;
        
        temp_valid	<=	1'b1;
        temp_ready	<=	1'b1;
		//storing the recieved values.
        temp_addr 	<= 	awaddr;
        temp_id 	<= 	awid;
        temp_len 	<= 	awlen;
        temp_size 	<= 	awsize;
        temp_burst 	<= 	awburst;
        //$display("writing to addr  %0h on ID = %0h",awaddr,awid);
      end
        
	//end

	if(awvalid ==0)begin
		awready <= 1'b0;

	end
      if(wvalid)begin //master
        wready <= 1'b1;//slave
        total_byte_size <= 2**(axi_wr_req_q[wid].awsize) *(axi_wr_req_q[wid].awlen);
        axi_wr_req_q[wid].wvalid <= wvalid;
      end
      if(axi_wr_req_q[wid].awvalid)begin
        case(axi_wr_req_q[wid].awburst)
    	0 : begin
          	for(int i=0; i<axi_wr_req_q[wid].awlen; i++)begin
              for(int ii=0; ii<2**(axi_wr_req_q[wid].awsize); ii++)begin
                if(wstrb[ii] && temp_valid)begin
                  mem[axi_wr_req_q[wid].awaddr+ii] 	<= wdata[8*ii +: 8];
                  /*$display("------------FIXED TYPE------------");
                  $display("--------Wdata = %h awaddr= %0h, strb = %0b-----------",wdata[8*ii +: 8],temp_addr,wstrb);
                  $display("--------Write to mem[%h] = %h -----------",axi_wr_req_q[wid].awaddr+ii,mem[axi_wr_req_q[wid].awaddr+ii]);
                  */
    				end
    			end
    		end
        end
      	1 : begin

            for(int i=0; i<axi_wr_req_q[wid].awlen; i++)begin
              for(int ii=0; ii<2**axi_wr_req_q[wid].awsize; ii++)begin
                if(wstrb[ii])begin
                  mem[axi_wr_req_q[wid].awaddr+ii] 	<= wdata[8*ii +: 8];
                  //$display("------------ %t INCR TYPE------------", $time);

                  //$display("--------Wdata = %h awaddr= %0h, strb = %0b-----------",wdata[8*ii +: 8],axi_wr_req_q[wid].awaddr,wstrb);
                  //$display("--------Write to mem[%h] = %h -----------",axi_wr_req_q[wid].awaddr+ii,mem[axi_wr_req_q[wid].awaddr+ii]);
                      
    				end// if(wstrb[ii])
            
              	// INCREMENT ADDR by 8
              	// TODO : Make it generic
                
              axi_wr_req_q[wid].awaddr <= axi_wr_req_q[wid].awaddr +`STROBE_SIZE;
    		end// for(int ii=0; ii<2**axi_wr_req_q[wid].awsize; ii++)
            end// for(int i=0; i<axi_wr_req_q[wid].awlen; i++)
          //axi_wr_req_q[wid].awvalid <= 0;
        end
      	2 : begin
       		//$display("------------WRAP TYPE------------");
			wrap_boundary <= (axi_wr_req_q[wid].awaddr / total_byte_size) * total_byte_size;
            $display("wrap_boundary = %0h", wrap_boundary);
          	for(int i=0; i<axi_wr_req_q[wid].awlen; i++)begin
              for(int ii=0; ii<2**(axi_wr_req_q[wid].awsize); ii++)begin
                	if(axi_wr_req_q[wid].awaddr+ii >= wrap_boundary+total_byte_size)
                      axi_wr_req_q[wid].awaddr<= axi_wr_req_q[wid].awaddr - wrap_boundary;
                	if(wstrb[ii])begin
                  		mem[axi_wr_req_q[wid].awaddr+ii] 	<= wdata[8*ii +: 8];
              			//$display("--------Wdata = %h awaddr= %0h, strb = %0b-----------",wdata,awaddr,wstrb);
                        //$display("--------Write to mem[%h] = %h -----------",axi_wr_req_q[wid].awaddr+ii,mem[axi_wr_req_q[wid].awaddr+ii]);
    				end
                	
                
    			end
    		end
        end
          
    endcase
        axi_wr_req_q[wid].awvalid<=0;
	end

	if(wvalid==0)begin
		wready<=0;
        //axi_wr_req_q[wid].wvalid <= 0;
	end
     
	if (wlast ==1)begin
   		do_write_response(wid);

	end
    if(!arvalid)begin
    	arready <= 1'b0;
    end 
      else if(arvalid) begin
      //$display("====read address phase started with ID = %0h====",rid);
    	read_addr_phase(arid);
    	rid <= arid;
  	end
  	if(!rready)
    	rvalid <= 1'b0;
      else if(rready) begin
      //$display("====read data phase started with ID = %0h====",rid);
    	rvalid <= 1'b1;
    	read_data_phase(rid);
  	end
end
end
task do_write_response(input [3:0]bid_t);
	//@(posedge aclk);
	bid<=bid_t;
	bresp <= 2'b00;
	bvalid <= 1;
  	while(bready=='b10)begin
		@(posedge aclk)begin
			bready_f<=1;// all tx are dn
		end
	end
endtask


task read_addr_phase(input [3:0]arid_t);
  	arready<=1;
	if (arvalid == 1)begin
      axi_rd_req_q[arid].arid			<= 	arid;
      axi_rd_req_q[arid].arvalid		<= 	arvalid;
      axi_rd_req_q[arid].arready		<=	arready;
	  //storing the recieved values.
      axi_rd_req_q[arid].araddr 		<= 	araddr;
      axi_rd_req_q[arid].arlen 		<= 	arlen;
      axi_rd_req_q[arid].arsize 		<= 	arsize;
      axi_rd_req_q[arid].arburst	    <= 	arburst;
      axi_rd_req_q[arid].arprot	    <= 	arprot;
      axi_rd_req_q[arid].arlock	    <= 	arlock;
      axi_rd_req_q[arid].arcache	    <= 	arcache;
	end
  
	if(arvalid==0)begin
		arready<=0;
	end
endtask

task read_data_phase(input [3:0] rid_t);
	bit arready_f;
    bit rready_f;
  
  	//$display("Inside read data phase arlen_t_arr[%0h] = %h",arid_t,arlen_t_arr[arid_t]);
  if(axi_rd_req_q[rid_t].arvalid)begin
    for(int i=0;i < axi_rd_req_q[rid_t].arlen;i++)begin
      	for(int j=0;j < `STROBE_SIZE;j++)begin
          //$display("--------read from mem[%0h] = %h",axi_rd_req_q[rid_t].araddr+j,mem[axi_rd_req_q[rid_t].araddr+j]);
		 	//storing the recieved values.    
          rdata[8*j +: 8] <=  	mem[axi_rd_req_q[rid_t].araddr+j] ;	
          rdata_temp <= mem[axi_rd_req_q[rid_t].araddr+j-1];
			//rid<=arid;
		
          if(j == axi_rd_req_q[rid_t].arsize-1)begin
	       		rlast<=1'b1;
				rready_f<=1'b0;
				rresp <= 2'b00;
			end
          
			while(rready_f==0)begin
				@(posedge aclk)begin
                  if(rready==1) rready_f<=1'b1;
				end
			end
     	end//       	for(int j=0;j < `STROBE_SIZE;j++)begin

      
      
	
	end//   	for(int i=0;i < temp_len;i++)begin
    axi_rd_req_q[rid_t].arvalid <= 0;
  end// if(axi_rd_req_q[rid_t].arvalid)
  @(posedge aclk);
	rlast<=0;
    bvalid<=0;
    rresp <= 'b111;
    bresp <= 'b111;
  
endtask

endmodule


