module packet_gen (
    input  logic [1:0]   router_destination,
    input  logic [1:0]   packet_type,
    input  logic         end_of_packet,
    input  logic [7:0]   payload,
    input  logic         valid,
    input  logic         src_ready,

    output logic         src_valid,
    output logic [12:0]  packet
);

assign src_valid  = valid;
assign packet = {router_destination, packet_type, 
                payload, end_of_packet};
endmodule