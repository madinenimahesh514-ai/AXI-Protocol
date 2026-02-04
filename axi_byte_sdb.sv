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
byte master_byteQ[$];
byte slave_byteQ[$];
byte master_byte;
byte slave_byte;
function void build();
  imp_master=new("imp_master",this);
  imp_slave=new("imp_slave",this);
endfunction

function void write_master(axi_tx tx);
axi_common::total_byte_count +=(tx.burst_len+1)*(2**tx.burst_size);
//master_txQ.push_back(tx);
foreach(tx.dataQ[i])begin
//for(int j=0;j<`DATA_SIZE/8 ;j++)begin
//end
   master_byteQ.push_back(tx.dataQ[i][7:0]);
   master_byteQ.push_back(tx.dataQ[i][15:8]);
   master_byteQ.push_back(tx.dataQ[i][23:16]);
   master_byteQ.push_back(tx.dataQ[i][31:24]);
end
endfunction

function void write_slave(axi_tx tx);
//slave_txQ.push_back(tx);
foreach(tx.dataQ[i])begin
//for(int j=0;j<`DATA_SIZE/8 ;j++)begin
//end
   slave_byteQ.push_back(tx.dataQ[i][7:0]);
   slave_byteQ.push_back(tx.dataQ[i][15:8]);
   slave_byteQ.push_back(tx.dataQ[i][23:16]);
   slave_byteQ.push_back(tx.dataQ[i][31:24]);
end

endfunction
task run();
forever begin
wait(master_byteQ.size() >0 && slave_byteQ.size() >0);
 master_byte=master_byteQ.pop_front();
 slave_byte=slave_byteQ.pop_front();
 if(master_byte==slave_byte)begin
      axi_common::match_count++; 
 end
 else begin
    axi_common::mismatch_count++;
 end
end
endtask

endclass

