module router (
    input logic clk,
    input logic n_rst,
    input logic fifo_wr_en,     // fifo write enable 

    input logic [9:0] packet,
    output logic [9:0] fifo_out 
);

logic [9:0] fifo, fifo2, fifo3, fifo4;
logic [1:0] counter, count;

// fifo-4
always_ff @( posedge clk or negedge n_rst ) begin
    if (!n_rst) 
        fifo <= '0;
    else if (fifo_wr_en) begin
        fifo <= packet;
        fifo2 <= fifo;
        fifo3 <= fifo2;
        fifo4 <= fifo3;
    end
    else begin
        fifo <= fifo;
        fifo2 <= fifo2;
        fifo3 <= fifo3;
        fifo4 <= fifo4;
    end
end

// counter
always_ff @(posedge clk or negedge n_rst) begin
    if (!n_rst) begin
        counter <= '0;
        count   <= '0;
    end else if (fifo_wr_en) begin
        count   <= count + 1;
        counter <= count;
    end else begin 
        count   <= count;
        counter <= counter;
    end
end

// fifo-out 
always_comb begin
    case (counter)
        2'b00:  fifo_out = fifo;
        2'b01:  fifo_out = fifo2;
        2'b10:  fifo_out = fifo3;
        2'b11:  fifo_out = fifo4;
        default: fifo_out = fifo_out;
    endcase
end

endmodule