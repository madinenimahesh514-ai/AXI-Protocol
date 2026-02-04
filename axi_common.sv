`define ADDR_SIZE 16
`define DATA_SIZE 32
`define STRB_SIZE	`DATA_SIZE/8
`define TX_COUNT 2
`define NEW_COMP \
function new(string name="",uvm_component parent);\
super.new(name,parent);\
endfunction
`define NEW_OBJ \
function new(string name="");\
super.new(name);\
endfunction
class axi_common;
static int match_count;
static int mismatch_count;
static int total_byte_count;
endclass
