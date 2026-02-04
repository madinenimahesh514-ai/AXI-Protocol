class axi_mon extends uvm_monitor;
`uvm_component_utils(axi_mon)
`NEW_COMP
virtual axi_intf vif;
axi_tx tx;
uvm_analysis_port#(axi_tx)ap_port;
function void build();
ap_port=new("ap_port",this);
if(!uvm_resource_db#(virtual axi_intf)::read_by_name("GLOBAL","PIF",vif,this))begin
   `uvm_info("AXI_MON","unable to get vif handdle",UVM_LOW)
end

endfunction

task run();
forever begin
  @( vif.mon_cb);
  if(vif.mon_cb.awvalid && vif.mon_cb.awready)begin
     tx=axi_tx::type_id::create("tx",this);
     tx.wr_rd=WRITE;
	  tx.addr=vif.mon_cb.awaddr;
	  tx.id=vif.mon_cb.awid;
	  tx.burst_len=vif.mon_cb.awlen;
	  tx.burst_size=vif.mon_cb.awsize;
	  tx.burst_type=vif.mon_cb.awburst;
	  tx.lock=vif.mon_cb.awlock;
	  tx.cache=vif.mon_cb.awcache;
	  tx.prot=vif.mon_cb.awprot;
  end
  if(vif.mon_cb.wvalid && vif.mon_cb.wready)begin
      tx.dataQ.push_back(vif.mon_cb.wdata);
	//	$display("write dataQ=%p",tx.dataQ);
		tx.strbQ.push_back(vif.mon_cb.wstrb);
		$display("addr=%h,wdata=%h",vif.mon_cb.awaddr,vif.mon_cb.wdata);
		ap_port.write(tx);
  end
  if(vif.mon_cb.bvalid && vif.mon_cb.bready)begin
  tx.respQ.push_back(vif.mon_cb.bresp);
  end
  if(vif.mon_cb.arvalid && vif.mon_cb.arready)begin
       tx=axi_tx::type_id::create("tx",this);
     tx.wr_rd=READ;
	  tx.addr=vif.mon_cb.araddr;
	  tx.id=vif.mon_cb.arid;
	  tx.burst_len=vif.mon_cb.arlen;
	  tx.burst_size=vif.mon_cb.arsize;
	  tx.burst_type=vif.mon_cb.arburst;
	  tx.lock=vif.mon_cb.arlock;
	  tx.cache=vif.mon_cb.arcache;
	  tx.prot=vif.mon_cb.arprot;

  end
  if(vif.mon_cb.rvalid && vif.mon_cb.rready)begin
      tx.dataQ.push_back(vif.mon_cb.rdata);
	//	$display("read dataQ=%p",tx.dataQ);
		$display("araddr=%h,rdata=%h",vif.mon_cb.araddr,vif.mon_cb.rdata);

		tx.respQ.push_back(vif.mon_cb.rresp);
       if(vif.mon_cb.rlast)ap_port.write(tx);
  end
end
endtask
endclass
