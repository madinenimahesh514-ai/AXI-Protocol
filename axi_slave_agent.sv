class axi_slave_agent extends uvm_agent;
`uvm_component_utils(axi_slave_agent)
`NEW_COMP
axi_responder resp;
axi_mon mon;
function void build();
mon=axi_mon::type_id::create("mon",this);
resp=axi_responder::type_id::create("resp",this);
endfunction

endclass
