module tb_top_module;
logic          clk, n_rst;

logic [1:0]   router_dest, m_dest;
logic [1:0]   packet_type, m_type;
logic         end_of_pack, m_eof;
logic [7:0]   payload, m_payload;
logic         valid;

logic         ready;

logic [9:0]   out_from_router1;
logic [9:0]   out_from_router2;
logic [9:0]   out_from_router3;
logic [9:0]   out_from_router4;

logic         invalid_packet;
logic         pass;

initial begin
    clk = 1;
    forever begin
        clk = #20 ~clk;
    end
end

top_module dut (
    .clk(clk),  .n_rst(n_rst),

    .router_destination(router_dest),
    .packet_type(packet_type),
    .end_of_packet(end_of_pack),
    .payload(payload),

    .valid(valid),

    .ready(ready),
    
    .out_from_router1(out_from_router1),
    .out_from_router2(out_from_router2),
    .out_from_router3(out_from_router3),
    .out_from_router4(out_from_router4),

    .invalid_packet(invalid_packet)
);

initial begin
    init_signals;
    reset_sequence;

    $display ("     Directed Test   \n");
    simple_test (2'b01, 2'b01, 8'hAB, 1'b1);

    $display (" Random Test \n");
    fork
        input_driver (10);
        valid_sequence;
        monitor;
    join_any


    @(posedge clk);
    $stop;
end

task input_driver(int tests);
    for (int i=0; i < tests; i++) begin
        @(posedge clk);
        router_dest = 0;
        packet_type = $random;
        payload     = $random;
        end_of_pack = $random;
        @(posedge clk);
        while (!ready) begin
            @(posedge clk);
        end
        @(posedge  clk);
    end
endtask

task valid_sequence;
    while (1) begin
        @(posedge clk);
        valid <= 1;
        @(posedge clk);
        while (!ready)
            @(posedge clk);
        valid <= '0; 
    end
endtask

task monitor;
    while(1) begin
        
        @(posedge valid);
        @(negedge valid);
        m_payload <= payload;
        m_type    <= packet_type;
        m_dest    <= router_dest;
        m_eof     <= end_of_pack;
        @(posedge clk);
        while (!ready)
            @(posedge clk);
        case (m_dest)
            2'b00: pass = (out_from_router1 == {m_type, m_payload});
            2'b01: pass = (out_from_router2 == {m_type, m_payload});
            2'b10: pass = (out_from_router3 == {m_type, m_payload});
            2'b11: pass = (out_from_router4 == {m_type, m_payload});
        endcase

        if (pass) begin
            $display ("Pass :)");
        end
        else if (!m_eof) begin
            $display ("In valid ");
        end
        else 
            $display ("Not Pass :|");
        pass <= 0;
    end

endtask

task simple_test(
    input logic [1:0] dest,
    input logic [1:0] p_type,
    input logic [7:0] data,
    input logic       eop);

    router_dest = dest;
    packet_type = p_type;
    payload     = data;
    end_of_pack = eop;
    @(posedge clk)
    valid <= 1;
    @(posedge clk);
    while(!ready)
        @(posedge clk);
    valid <= '0;
    @(posedge clk);

endtask

task init_signals;
    valid <= '0;

    router_dest = '0;    packet_type = '0;
    end_of_pack = '0;    payload = '0;
endtask

task reset_sequence;
    n_rst <= '0;
    @(posedge clk);
    n_rst <= 1;
    @(posedge clk);
endtask

endmodule