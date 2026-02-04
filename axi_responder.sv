class axi_responder extends uvm_component;
byte mem[int];
//write addr channel
bit[`ADDR_SIZE-1:0]awaddr_t;
bit [3:0]awid_t;
bit[3:0]awlen_t;
bit[1:0]awburst_t;
bit[2:0]awsize_t;
//read addr channel
bit[`ADDR_SIZE-1:0]araddr_t;
bit [3:0]arid_t;
bit[3:0]arlen_t;
bit[1:0]arburst_t;
bit[2:0]arsize_t;
int beat_count;

`uvm_component_utils(axi_responder)
`NEW_COMP
virtual axi_intf vif;
function void build();
if(!uvm_resource_db#(virtual axi_intf)::read_by_name("GLOBAL","PIF",vif,this))begin
   `uvm_info("AXI_DRV","unable to get vif handdle",UVM_LOW)
end
endfunction

task run();
forever begin
@(posedge vif.aclk);
vif.awready=0;
vif.wready=0;
vif.arready=0;

//write addr  handshake
if(vif.awvalid)begin
 vif.awready=1;
//collect the write addr information
awaddr_t =vif.awaddr;
awlen_t=vif.awlen;
awsize_t=vif.awsize;
awburst_t=vif.awburst;
awid_t=vif.awid;
//set ignore first beat
beat_count=0;
 end
 //write data handshake
 if(vif.wvalid)begin
     vif.wready=1;
  if(beat_count>0)begin
    store_wdata_to_mem(vif.wdata,vif.wstrb);
  end
beat_count++;
   if (vif.wlast==1)begin
fork
    drive_write_resp(vif.wid);
join_none
   end
  end
 //read addr handshake
 if(vif.arvalid)begin
   vif. arready=1;
//collect the read addr information
araddr_t =vif.araddr;
arlen_t=vif.arlen;
arsize_t=vif.arsize;
arburst_t=vif.arburst;
arid_t=vif.arid;
drive_read_data(vif.arid);
 end
end
endtask
task drive_read_data(bit [3:0]id);
for(int i=0;i<=arlen_t;i++)begin
@(posedge vif.aclk);
vif.rid=id;
vif.rlast=(i==arlen_t)?1'b1:1'b0;
vif.rdata={mem[araddr_t+3],
           mem[araddr_t+2],
           mem[araddr_t+1],
           mem[araddr_t+0]
                };
//`uvm_warning("mem_read",$sformatf("addr=%h,data=%h",araddr_t,vif.rdata));
//`uvm_info("mem_read",$sformatf("addr=%h,data=%h",araddr_t,vif.rdata),UVM_LOW);
//$display("read addr=%h,data=%h",araddr_t,vif.rdata);
vif.rresp=OKAY;
vif.rvalid=1;
wait(vif.rready==1);
//for the next beat we have to read
araddr_t=araddr_t+2**arsize_t;
end
reset_read_data();
endtask
task reset_read_data();
@(posedge  vif.aclk);
vif.rid=0;
vif.rvalid=0;
vif.rresp=OKAY;
vif.rdata=0;
vif.rlast=0;
endtask

task drive_write_resp(bit [3:0]id);
@(posedge  vif.aclk);
vif.bid=id;

vif.bresp=OKAY;
vif.bvalid=1;
wait(vif.bready==1);
reset_write_resp();
endtask
task reset_write_resp();
@(posedge vif.aclk);
vif.bid=0;
vif.bvalid=0;
vif.bresp=OKAY;

endtask
function void store_wdata_to_mem(bit[`DATA_SIZE-1:0]data,
bit [`STRB_SIZE-1:0]strb
);
bit[`DATA_SIZE-1:0]wdata;
bit[`STRB_SIZE-1:0]wstrb;
wdata=data;
wstrb=strb;
for(int i=0;i<`DATA_SIZE/8;i++)begin
if(wstrb[i]==1)begin
//`uvm_warning("mem_write",$sformatf("addr=%h,data=%h",awaddr_t,wdata[7:0]));
//`uvm_info("mem_write",$sformatf("addr=%h,data=%h",awaddr_t,wdata[7:0]),UVM_LOW);

//$display("write addr=%h,data=%h",awaddr_t,wdata[7:0]);
    mem[awaddr_t]=wdata[7:0];
     awaddr_t++;//next byte needs to be stored into next addr(+1)
     // data >>=8;
end
wdata >>=8;//right shift operation to print next upper byte to 7:0 position
//awaddr_t=awaddr_t+2**awsize_t;

end
//awaddr_t=awaddr_t+2**awsize_t;

endfunction
endclass

/*class axi_responder extends uvm_component;
byte mem[int];
//write addr channel
bit[`ADDR_SIZE-1:0]awaddr_t;
bit [3:0]awid_t;
bit[3:0]awlen_t;
bit[1:0]awburst_t;
bit[2:0]awsize_t;
//read addr channel
bit[`ADDR_SIZE-1:0]araddr_t;
bit [3:0]arid_t;
bit[3:0]arlen_t;
bit[1:0]arburst_t;
bit[2:0]arsize_t;
int beat_count;

`uvm_component_utils(axi_responder)
`NEW_COMP
virtual axi_intf vif;
function void build();
if(!uvm_resource_db#(virtual axi_intf)::read_by_name("GLOBAL","PIF",vif,this))begin
   `uvm_info("AXI_DRV","unable to get vif handdle",UVM_LOW)
end
endfunction

task run();
forever begin
@( vif.resp_cb);
vif.resp_cb.awready<=0;
vif.resp_cb.wready<=0;
vif.resp_cb.arready<=0;

//write addr  handshake
if(vif.resp_cb.awvalid)begin
 vif.resp_cb.awready<=1;
//collect the write addr information
awaddr_t =vif.resp_cb.awaddr;
awlen_t=vif.resp_cb.awlen;
awsize_t=vif.resp_cb.awsize;
awburst_t=vif.resp_cb.awburst;
awid_t=vif.resp_cb.awid;
//set ignore first beat
beat_count=0;
 end
 //write data handshake
 if(vif.resp_cb.wvalid)begin
     vif.resp_cb.wready<=1;
  if(beat_count>1)begin
    store_wdata_to_mem(vif.resp_cb.wdata,vif.resp_cb.wstrb);
  end
beat_count++;
   if (vif.resp_cb.wlast==1)begin
fork
    drive_write_resp(vif.resp_cb.wid);
join_none
   end
  end
 //read addr handshake
 if(vif.resp_cb.arvalid)begin
   vif.resp_cb. arready<=1;
//collect the read addr information
araddr_t =vif.resp_cb.araddr;
arlen_t=vif.resp_cb.arlen;
arsize_t=vif.resp_cb.arsize;
arburst_t=vif.resp_cb.arburst;
arid_t=vif.resp_cb.arid;
drive_read_data(vif.resp_cb.arid);
 end
end
endtask
task drive_read_data(bit [3:0]id);
for(int i=0;i<=arlen_t;i++)begin
@(vif.resp_cb);
vif.resp_cb.rid<=id;
vif.resp_cb.rlast<=(i==arlen_t)?1'b1:1'b0;
vif.resp_cb.rdata<={mem[araddr_t+3],
           mem[araddr_t+2],
           mem[araddr_t+1],
           mem[araddr_t+0]
                };
//`uvm_warning("mem_read",$sformatf("addr=%h,data=%h",araddr_t,vif.resp_cb.rdata));
//`uvm_info("mem_read",$sformatf("addr=%h,data=%h",araddr_t,vif.resp_cb.rdata),UVM_LOW);
//$display("read addr=%h,data=%h",araddr_t,vif.resp_cb.rdata);
vif.resp_cb.rresp<=OKAY;
vif.resp_cb.rvalid<=1;
wait(vif.resp_cb.rready==1);
//for the next beat we have to read
araddr_t=araddr_t+2**arsize_t;
end
reset_read_data();
endtask
task reset_read_data();
@( vif.resp_cb);
vif.resp_cb.rid<=0;
vif.resp_cb.rvalid<=0;
vif.resp_cb.rresp<=OKAY;
vif.resp_cb.rdata<=0;
vif.resp_cb.rlast<=0;
endtask

task drive_write_resp(bit [3:0]id);
@( vif.resp_cb);
vif.resp_cb.bid<=id;

vif.resp_cb.bresp<=OKAY;
vif.resp_cb.bvalid<=1;
wait(vif.resp_cb.bready==1);
reset_write_resp();
endtask
task reset_write_resp();
@(vif.resp_cb);
vif.resp_cb.bid<=0;
vif.resp_cb.bvalid<=0;
vif.resp_cb.bresp<=OKAY;

endtask
function void store_wdata_to_mem(bit[`DATA_SIZE-1:0]data,
bit [`STRB_SIZE-1:0]strb
);
bit[`DATA_SIZE-1:0]wdata;
bit[`STRB_SIZE-1:0]wstrb;
wdata=data;
wstrb=strb;
for(int i=0;i<`DATA_SIZE/8;i++)begin
if(wstrb[i]==1)begin
//`uvm_warning("mem_write",$sformatf("addr=%h,data=%h",awaddr_t,wdata[7:0]));
//`uvm_info("mem_write",$sformatf("addr=%h,data=%h",awaddr_t,wdata[7:0]),UVM_LOW);

//$display("write addr=%h,data=%h",awaddr_t,wdata[7:0]);
    mem[awaddr_t]=wdata[7:0];
     awaddr_t++;//next byte needs to be stored into next addr(+1)
     // data >>=8;
end
wdata >>=8;//right shift operation to print next upper byte to 7:0 position
//awaddr_t=awaddr_t+2**awsize_t;

end
//awaddr_t=awaddr_t+2**awsize_t;

endfunction
endclass*/
