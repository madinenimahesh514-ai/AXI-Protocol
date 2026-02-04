class axi_cov extends uvm_subscriber#(axi_tx);
`uvm_component_utils(axi_cov)

function new(string name="",uvm_component parent);
super.new(name,parent);
axi_cg=new();
endfunction
axi_tx tx;
covergroup axi_cg;
CP_ADDR:coverpoint tx.addr{
option.auto_bin_max=16;

}
CP_BURST_LEN:coverpoint tx.burst_len{
option.auto_bin_max=16;

}
CP_WR_RD:coverpoint tx.wr_rd{
bins WRITE={WRITE};
bins READ={READ};
}
CP_ADDR_X_CP_WR_RD:cross CP_ADDR,CP_WR_RD;
CP_ID:coverpoint tx.id{
option.auto_bin_max=16;
}
CP_BURST_SIZE:coverpoint tx.burst_size{
bins BURST_SIZE_1BYTE={3'h0};
bins BURST_SIZE_2BYTE={3'h1};
bins BURST_SIZE_4BYTE={3'h2};
bins BURST_SIZE_8BYTE={3'h3};
bins BURST_SIZE_16BYTE={3'h4};
bins BURST_SIZE_32BYTE={3'h5};
bins BURST_SIZE_64BYTE={3'h6};
bins BURST_SIZE_128BYTE={3'h7};
}
CP_BURST_TYPE:coverpoint tx.burst_type{
bins FIXED_BURST={FIXED};
bins INCR_BURST={INCR};
bins WRAP_BURST={WRAP};
illegal_bins RSVD_BURST={RSVD_BURST};
}
CP_RESPQ:coverpoint tx.respQ[0]{
bins OKAY={OKAY};
bins EXOKAY={EXOKAY};
bins SLVERR={SLERR};
bins DECERR={DECERR};
}

endgroup
function void write(axi_tx t);
$cast(tx,t);
axi_cg.sample();
endfunction

endclass
