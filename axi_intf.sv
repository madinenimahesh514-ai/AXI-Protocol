interface axi_intf(input bit aclk,arst);
//write addr channel
bit[`ADDR_SIZE-1:0]awaddr;
bit [3:0]awid;
bit[3:0]awlen;
bit[1:0]awburst;
bit[2:0]awsize;
bit[1:0]awlock;
bit[1:0]awcache;
bit awvalid,awready;
bit[2:0]awprot;

//write data channel
bit[`DATA_SIZE-1:0]wdata;
bit [`STRB_SIZE-1:0]wstrb;
bit[3:0]wid;
bit wvalid,wready,wlast;

//write resp channel
bit [3:0]bid;
bit bready,bvalid;
bit [1:0]bresp;

//read addr channel
bit[`ADDR_SIZE-1:0]araddr;
bit [3:0]arid;
bit[3:0]arlen;
bit[1:0]arburst;
bit[2:0]arsize;
bit[1:0]arlock;
bit[1:0]arcache;
bit arvalid,arready;
bit[2:0]arprot;

//read data channel
bit[`DATA_SIZE-1:0]rdata;
bit[3:0]rid;
bit rvalid,rready,rlast;
bit [1:0]rresp;

clocking drv_cb@(posedge aclk);
default input #1 output #0;
//10,00,
//write addr channels
output awaddr, awid,awlen, awburst, awsize, awlock, awcache, awvalid,awprot;
input awready;

//write data channel
output wdata, wstrb, wid, wvalid,wlast;
input  wready;

//write resp channel
output bready;
input bid, bvalid, bresp;

//read addr channel
output araddr, arid, arlen, arburst, arsize, arlock, arcache, arvalid;
input  arready;

//read data channel
input rdata, rid, rvalid, rlast, rresp;
output rready;

endclocking

clocking resp_cb@(posedge aclk);
default input #0 output #0;
//10,00,
//write addr channels
input awaddr, awid,awlen, awburst, awsize, awlock, awcache, awvalid,awprot;
output awready;
//write data channel
input wdata, wstrb, wid, wvalid,wlast;
output  wready;
//write resp channel
input bready;
output bid, bvalid, bresp;
//read addr channel
input araddr, arid, arlen, arburst, arsize, arlock, arcache, arvalid;
output  arready;
//read data channel
output rdata, rid, rvalid, rlast, rresp;
input rready;
endclocking

clocking mon_cb@(posedge aclk);
default input #1;
//10,00,
//write addr channels
input awaddr, awid,awlen, awburst, awsize, awlock, awcache, awvalid,awprot;
input awready;

//write data channel
input wdata, wstrb, wid, wvalid,wlast;
input  wready;

//write resp channel
input bready;
input bid, bvalid, bresp;

//read addr channel
input araddr, arid, arlen, arburst, arsize, arlock, arcache, arvalid,arprot;
input  arready;

//read data channel
input rdata, rid, rvalid, rlast, rresp;
input rready;
endclocking

endinterface
