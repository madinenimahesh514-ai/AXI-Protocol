class axi_base_test extends uvm_test;
`uvm_component_utils(axi_base_test)
`NEW_COMP
axi_env env;
function void build();
env=axi_env::type_id::create("env",this);
endfunction
function void end_of_elaboration();
uvm_top.print_topology();
endfunction
function void report();
 if(axi_common::match_count==2*`TX_COUNT && axi_common::mismatch_count==0)begin
// if(axi_common::match_count==axi_common::total_byte_count && axi_common::mismatch_count==0)begin
    `uvm_info("TESTCASE_STATUS",$psprintf("%s test passed*******",get_type_name()),UVM_NONE)
 end
 else begin
   `uvm_info("TEST_STATUS",$psprintf("%s test failed,match_count=%0d,mismatch_count=%0d",get_type_name(),axi_common::match_count,axi_common::mismatch_count),UVM_NONE)
 end
endfunction
endclass
class axi_wr_rd_test extends axi_base_test;
`uvm_component_utils(axi_wr_rd_test)
`NEW_COMP
task run_phase(uvm_phase phase);
axi_wr_rd_seq wr_rd_seq=new("tx");
phase.raise_objection(this);
phase.phase_done.set_drain_time(this,200);
wr_rd_seq.start(env.m_agent.sqr);
phase.drop_objection(this);
endtask
endclass

class axi_n_wr_n_rd_test extends axi_base_test;
`uvm_component_utils(axi_n_wr_n_rd_test)
`NEW_COMP
function void build();
super.build();
uvm_resource_db#(int)::set("GLOBAL","COUNT",`TX_COUNT,this);
endfunction
task run_phase(uvm_phase phase);
axi_n_wr_n_rd_seq n_wr_n_rd_seq=new("tx");
phase.raise_objection(this);
phase.phase_done.set_drain_time(this,200);
n_wr_n_rd_seq.start(env.m_agent.sqr);
phase.drop_objection(this);
endtask

endclass

