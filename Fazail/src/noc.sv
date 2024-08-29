module noc (
    input  logic clk,
    input  logic n_rst,

    input logic src_valid,
    input  logic [12:0] packet,
    
    output logic [9:0] out_from_router1,
    output logic [9:0] out_from_router2,
    output logic [9:0] out_from_router3,
    output logic [9:0] out_from_router4,

    output logic invalid_packet,
    output logic src_ready
);

logic fifo1_wr_en, fifo2_wr_en, fifo3_wr_en, fifo4_wr_en;
logic [1:0]dst, pkt_type; // destination router
logic eop;                // end of packet  

// destination selection
assign dst = packet [12:11];

// type of packet
assign invalid_pkt = (packet [10:9] == 2'b11);

// End of Packet
assign eop = packet [0];

// controller for noc
noc_controller controller (
    .clk(clk),  .n_rst(n_rst),

    .dst(dst),  .end_of_packet(eop),
    .invalid_type(invalid_pkt),

    .src_valid (src_valid),

    .fifo1_wr_en(fifo1_wr_en),
    .fifo2_wr_en(fifo2_wr_en),
    .fifo3_wr_en(fifo3_wr_en),
    .fifo4_wr_en(fifo4_wr_en),

    .invalid_packet(invalid_packet),

    .src_ready(src_ready)
);


router router1 (
    .clk(clk), .n_rst(n_rst),

    .fifo_wr_en(fifo1_wr_en),
    .packet(packet[10:1]),

    .fifo_out(out_from_router1)
);

router router2 (
    .clk(clk), .n_rst(n_rst),

    .fifo_wr_en(fifo2_wr_en),
    .packet(packet[10:1]),

    .fifo_out(out_from_router2)
);

router router3 (
    .clk(clk), .n_rst(n_rst),

    .fifo_wr_en(fifo3_wr_en),
    .packet(packet[10:1]),

    .fifo_out(out_from_router3)
);

router router4 (
    .clk(clk), .n_rst(n_rst),

    .fifo_wr_en(fifo4_wr_en),
    .packet(packet[9:0]),

    .fifo_out(out_from_router4)
);

endmodule