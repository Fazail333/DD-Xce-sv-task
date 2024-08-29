module noc_controller (
    input logic clk,
    input logic n_rst,

    input logic [1:0] dst,
    input logic end_of_packet, 
    input logic invalid_type,

    input logic src_valid,

    output logic fifo1_wr_en,
    output logic fifo2_wr_en,
    output logic fifo3_wr_en,
    output logic fifo4_wr_en,

    output logic invalid_packet,

    output logic src_ready
);

typedef enum logic [1:0] { IDLE, HANDSHAKE, INVALID} state_e;

state_e c_state, n_state;

// State register
always_ff @(posedge clk) begin
    if (!n_rst)
        c_state <= IDLE;
    else 
        c_state <= n_state;
end

always_comb begin
    case(c_state)
        IDLE: begin
            if (src_valid) begin
                if (!end_of_packet | invalid_type)
                    n_state = INVALID;
                else
                    n_state = HANDSHAKE;
            end
            else 
                n_state = IDLE;
        end

        HANDSHAKE: begin
            n_state = IDLE;
        end

        INVALID: begin
            n_state = IDLE;
        end
    endcase
end

always_comb begin
    case(c_state)
        IDLE: begin
            src_ready   = 1;
            if (src_valid) begin
            if (!end_of_packet | invalid_packet)begin
                fifo1_wr_en = '0;
                fifo2_wr_en = '0;
                fifo3_wr_en = '0;
                fifo4_wr_en = '0;
                invalid_packet = 1;
            end else begin
                invalid_packet = 0;
                case(dst)
                    2'b00: fifo1_wr_en = 1'b1;
                    2'b01: fifo2_wr_en = 1'b1;
                    2'b10: fifo3_wr_en = 1'b1;
                    2'b11: fifo4_wr_en = 1'b1;
                endcase
            end
            end else begin
                invalid_packet = '0;
                fifo1_wr_en = '0;
                fifo2_wr_en = '0;
                fifo3_wr_en = '0;
                fifo4_wr_en = '0;
            end
        end

        INVALID: begin
                src_ready   = 0;
                fifo1_wr_en = '0;
                fifo2_wr_en = '0;
                fifo3_wr_en = '0;
                fifo4_wr_en = '0;
                invalid_packet = 1;
        end

        HANDSHAKE: begin
            // fifo1_wr_en = '0;
            // fifo2_wr_en = '0;
            // fifo3_wr_en = '0;
            // fifo4_wr_en = '0;
            case(dst)
                    2'b00: fifo1_wr_en = 1'b1;
                    2'b01: fifo2_wr_en = 1'b1;
                    2'b10: fifo3_wr_en = 1'b1;
                    2'b11: fifo4_wr_en = 1'b1;
            endcase
            src_ready   = 0;
            invalid_packet = '0;
        end
    endcase
end

endmodule