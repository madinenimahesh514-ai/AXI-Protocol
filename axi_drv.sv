class axi_drv extends uvm_driver#(axi_tx);
`uvm_component_utils(axi_drv)
`NEW_COMP
virtual axi_intf vif;
function void build();
if(!uvm_resource_db#(virtual axi_intf)::read_by_name("GLOBAL","PIF",vif,this))begin
   `uvm_info("AXI_DRV","unable to get vif handdle",UVM_LOW)
end
endfunction

task run();
forever begin
seq_item_port.get_next_item(req);
axi_common::total_byte_count +=(req.burst_len+1)*(2**req.burst_size);
//req.print();
drive_tx(req);
seq_item_port.item_done();
end
endtask

task drive_tx(axi_tx tx);
if(tx.wr_rd==WRITE)begin
//write addr channel
write_addr(tx);
//write data channel
write_data(tx);
//write response channel
write_resp(tx);
end

if(tx.wr_rd==READ)begin
//read addr channel
read_addr(tx);
//read data channel
read_data(tx);
end
endtask

task write_addr(axi_tx tx);
`uvm_info("WRITE ADDR","write addr ",UVM_LOW)
@( vif.drv_cb);
vif.drv_cb.awaddr<=tx.addr;
vif.drv_cb.awid<=tx.id;
vif.drv_cb.awlen<=tx.burst_len;
vif.drv_cb.awburst<=tx.burst_type;
vif.drv_cb.awsize<=tx.burst_size;
vif.drv_cb.awlock<=tx.lock;
vif.drv_cb.awcache<=tx.cache;
vif.drv_cb.awvalid<=1'b1;
wait(vif.drv_cb.awready==1);
write_addr_reset();
endtask

task write_data(axi_tx tx);
`uvm_info("WRITE DATA","write DATA ",UVM_LOW)
for(int i=0;i<=tx.burst_len;i++)begin
@( vif.drv_cb);
vif.drv_cb.wdata<=tx.dataQ[i];//.pop_front();
vif.drv_cb.wstrb<=tx.strbQ[i];//.pop_front();
vif.drv_cb.wid<=tx.id;
vif.drv_cb.wvalid<=1;
if(i==tx.burst_len)vif.drv_cb.wlast<=1;
wait(vif.drv_cb.wready==1);
end
reset_write_data();
endtask

task write_resp(axi_tx tx);
`uvm_info("WRITE resp","write resp ",UVM_LOW)
while(vif.drv_cb.bvalid == 1'b0)begin
   @( vif.drv_cb);
end

if(vif.drv_cb.bvalid==1)begin
   vif.drv_cb.bready<=1;
   @( vif.drv_cb);
   vif.drv_cb.bready<=0;
end
endtask

task read_addr(axi_tx tx);
`uvm_info("READ ADDR","READ addr ",UVM_LOW)
@(vif.drv_cb);
vif.drv_cb.araddr<=tx.addr;
vif.drv_cb.arid<=tx.id;
vif.drv_cb.arlen<=tx.burst_len;
vif.drv_cb.arburst<=tx.burst_type;
vif.drv_cb.arsize<=tx.burst_size;
vif.drv_cb.arlock<=tx.lock;
vif.drv_cb.arcache<=tx.cache;
vif.drv_cb.arvalid<=1'b1;
wait(vif.drv_cb.arready==1);
reset_read_addr();
endtask

task read_data(axi_tx tx);
`uvm_info("READ DATA","READ DATA ",UVM_LOW)
//till the slave doesn't give valid read data,keep loop at edge of clock
for(int i=0;i<=tx.burst_len;i++)begin
while(vif.drv_cb.rvalid==1'b0)begin
@( vif.drv_cb);
end
if(vif.drv_cb.rvalid==1)begin
   vif.drv_cb.rready<=1;
   tx.dataQ.push_back(vif.drv_cb.rdata);
   @( vif.drv_cb);
   vif.drv_cb.rready<=0;
end
end
endtask

task write_addr_reset();
@( vif.drv_cb);
vif.drv_cb.awaddr<=0;
vif.drv_cb.awid<=0;
vif.drv_cb.awlen<=0;
vif.drv_cb.awburst<=0;
vif.drv_cb.awsize<=0;
vif.drv_cb.awlock<=0;
vif.drv_cb.awcache<=0;
vif.drv_cb.awvalid<=0;
endtask

task reset_write_data();
@( vif.drv_cb);
vif.drv_cb.wdata<=0;
vif.drv_cb.wstrb<=0;
vif.drv_cb.wid<=0;
vif.drv_cb.wvalid<=0;
vif.drv_cb.wlast<=0;
endtask

task reset_read_addr();
@( vif.drv_cb);
vif.drv_cb.araddr<=0;
vif.drv_cb.arid<=0;
vif.drv_cb.arlen<=0;
vif.drv_cb.arburst<=0;
vif.drv_cb.arsize<=0;
vif.drv_cb.arlock<=0;
vif.drv_cb.arcache<=0;
vif.drv_cb.arvalid<=0;
endtask

endclass
