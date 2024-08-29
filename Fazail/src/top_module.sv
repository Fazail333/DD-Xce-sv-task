module top_module (
    input logic          clk, n_rst,

    input  logic [1:0]   router_destination,
    input  logic [1:0]   packet_type,
    input  logic         end_of_packet,
    input  logic [7:0]   payload,
    input  logic         valid,

    output logic         ready,

    output logic [9:0]   out_from_router1,
    output logic [9:0]   out_from_router2,
    output logic [9:0]   out_from_router3,
    output logic [9:0]   out_from_router4,

    output logic         invalid_packet
);

logic [12:0]  packet;

packet_gen packet_generation (
    .router_destination(router_destination),
    .packet_type(packet_type),
    .end_of_packet(end_of_packet),
    .payload(payload),

    .src_ready(ready),

    .valid(valid),
    .src_valid (src_valid),

    .packet(packet)

);

noc NOC (
    .clk(clk), .n_rst(n_rst),
    .src_valid(src_valid), .packet(packet),

    .out_from_router1(out_from_router1),
    .out_from_router2(out_from_router2),
    .out_from_router3(out_from_router3),
    .out_from_router4(out_from_router4),

    .invalid_packet(invalid_packet),
    .src_ready(ready)
);

endmodule