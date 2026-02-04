`timescale 1ns/1ns
`include "uvm_pkg.sv"
import uvm_pkg::*;
`include "axi_common.sv"
`include "axi_tx.sv"
`include "axi_intf.sv"
`include "axi_mon.sv"
`include "axi_cov.sv"
`include "axi_drv.sv"
`include "axi_sqr.sv"
`include "axi_master_agent.sv"
`include "axi_responder.sv"
`include "axi_slave_agent.sv"
`include "axi_seq_lib.sv"
//`include "axi_byte_sdb.sv"
`include "axi_sbd.sv"
`include "axi_env.sv"
`include "test_lib.sv"

module top;
  reg aclk, arst;
  axi_intf pif(aclk, arst);

  initial begin
    aclk = 0;
    forever #5 aclk = ~aclk;
  end

  initial begin
    uvm_resource_db#(virtual axi_intf)::set("GLOBAL", "PIF", pif, null);
    arst = 1;
    repeat(1) @(posedge aclk);
    arst = 0;
  end

  initial begin
    run_test("axi_n_wr_n_rd_test");
  end

  initial begin
    $fsdbDumpfile("axi.fsdb");
    $fsdbDumpvars(0);
  end
endmodule



/*`include "uvm_pkg.sv"
import uvm_pkg::*;
`include "axi_common.sv"
`include "axi_tx.sv"
`include "axi_intf.sv"
`include "axi_mon.sv"
`include "axi_cov.sv"
`include "axi_drv.sv"
`include "axi_sqr.sv"

`include "axi_master_agent.sv"
`include "axi_responder.sv"
`include "axi_slave_agent.sv"
`include "axi_seq_lib.sv"
`include "axi_env.sv"
`include "test_lib.sv"

module top;
reg aclk,arst;
axi_intf pif(aclk,arst);
initial begin
aclk=0;
forever #5 aclk=~aclk;
end
initial begin
uvm_resource_db#(virtual axi_intf)::set("GLOBAL","PIF",pif,null);
arst=1;
repeat(2)@(posedge aclk);
arst=0;
end
initial begin
run_test("axi_n_wr_n_rd_test");
end
//initial begin
//$fsdbDumpfile("1.fsdb");
//$fsdbDumvars(0);
//end
initial begin
  $fsdbDumpfile("axi.fsdb");
$fsdbDumpvars(0);
end
endmodule*/
