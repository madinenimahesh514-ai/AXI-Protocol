`uvm_analysis_imp_decl(_master)
//1.it defienes a TLM class :uvm_analysis_imp_master
//2.it provides a method called:write_master
`uvm_analysis_imp_decl(_slave)
//1.it defienes a TLM class :uvm_analysis_imp_slave
//2.it provides a method called:write_slave
class axi_sbd extends uvm_scoreboard;
uvm_analysis_imp_master#(axi_tx,axi_sbd) imp_master;
uvm_analysis_imp_slave#(axi_tx,axi_sbd) imp_slave;
`uvm_component_utils(axi_sbd)
`NEW_COMP
axi_tx master_txQ[$];
axi_tx slave_txQ[$];
axi_tx master_tx;
axi_tx slave_tx;
function void build();
  imp_master=new("imp_master",this);
  imp_slave=new("imp_slave",this);
endfunction

function void write_master(axi_tx tx);
master_txQ.push_back(tx);
endfunction

function void write_slave(axi_tx tx);
slave_txQ.push_back(tx);
endfunction
task run();
forever begin
wait(master_txQ.size() >0 && slave_txQ.size() >0);
 master_tx=master_txQ.pop_front();
 slave_tx=slave_txQ.pop_front();
 if(master_tx.compare(slave_tx))begin
      axi_common::match_count++; 
 end
 else begin
    axi_common::mismatch_count++;
 end
end
endtask

endclass

