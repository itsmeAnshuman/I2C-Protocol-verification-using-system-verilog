`timescale 1ns / 1ps
module i2c_Slave(
input scl,clk,rst,
inout sda,
output reg ack_err, done
);

typedef enum logic [3:0] {
    idle = 0, read_addr = 1, send_ack1 = 2, send_data = 3,
    master_ack = 4, read_data = 5, send_ack2 = 6, wait_p = 7, detect_stop = 8
} state_type;
state_type state = idle;

reg [7:0] mem [128];
reg [7:0] r_addr;
reg [6:0] addr;
reg r_mem = 0;
reg w_mem = 0;
reg [7:0] dout;
reg [7:0] din;
reg sda_t;
reg sda_en;
reg [3:0] bitcnt = 0;

always @(posedge clk) begin
    if (rst) begin
        for (int i = 0; i < 128; i++) mem[i] = i;
        dout <= 8'h0;
    end else if (r_mem) begin
        dout <= mem[addr];
    end else if (w_mem) begin
        mem[addr] <= din;
    end
end

parameter sys_freq = 40000000;
parameter i2c_freq = 100000;
parameter clk_count4 = (sys_freq / i2c_freq);
parameter clk_count1 = clk_count4 / 4;

integer count1 = 0;
reg [1:0] pulse = 0;
reg busy;

always @(posedge clk) begin
    if (rst) begin
        pulse <= 0; count1 <= 0;
    end else if (!busy) begin
        pulse <= 2; count1 <= 202;
    end else if (count1 == clk_count1 - 1) begin
        pulse <= 1; count1 <= count1 + 1;
    end else if (count1 == clk_count1*2 - 1) begin
        pulse <= 2; count1 <= count1 + 1;
    end else if (count1 == clk_count1*3 - 1) begin
        pulse <= 3; count1 <= count1 + 1;
    end else if (count1 == clk_count1*4 - 1) begin
        pulse <= 0; count1 <= 0;
    end else begin
        count1 <= count1 + 1;
    end
end

reg scl_t;
wire start;
always @(posedge clk) scl_t <= scl;
assign start = ~sda & scl_t;

reg r_ack;

always @(posedge clk) begin
    if (rst) begin
        bitcnt <= 0; state <= idle;
        r_addr <= 0; sda_en <= 0; sda_t <= 0;
        addr <= 0; r_mem <= 0; w_mem <= 0;
        din <= 8'h00; ack_err <= 0; done <= 0; busy <= 0;
    end else begin
        case(state)
        idle: begin
            if (scl && !sda) begin
                busy <= 1; state <= wait_p;
            end
        end
        wait_p: begin
            if (pulse == 2'b11 && count1 == 399)
                state <= read_addr;
        end
        read_addr: begin
            sda_en <= 0;
            if (bitcnt <= 7) begin
                if (pulse == 2 && count1 == 200)
                    r_addr <= {r_addr[6:0], sda};
                if (count1 == clk_count1*4 - 1)
                    bitcnt <= bitcnt + 1;
            end else begin
                state <= send_ack1; bitcnt <= 0;
                addr <= r_addr[7:1]; sda_en <= 1;
            end
        end
        send_ack1: begin
            if (pulse == 0) sda_t <= 0;
            if (count1 == clk_count1*4 - 1) begin
                if (r_addr[0]) begin
                    r_mem <= 1; state <= send_data;
                end else begin
                    r_mem <= 0; state <= read_data;
                end
            end
        end
        read_data: begin
            sda_en <= 0;
            if (bitcnt <= 7) begin
                if (pulse == 2 && count1 == 200)
                    din <= {din[6:0], sda};
                if (count1 == clk_count1*4 - 1)
                    bitcnt <= bitcnt + 1;
            end else begin
                state <= send_ack2; bitcnt <= 0;
                sda_en <= 1; w_mem <= 1;
            end
        end
        send_ack2: begin
            if (pulse == 0) sda_t <= 0;
            if (pulse == 1) w_mem <= 0;
            if (count1 == clk_count1*4 - 1) begin
                sda_en <= 0; state <= detect_stop;
            end
        end
        send_data: begin
            sda_en <= 1; r_mem <= 0;
            if (bitcnt <= 7) begin
                if (pulse == 1 && count1 == 100)
                    sda_t <= dout[7 - bitcnt];
                if (count1 == clk_count1*4 - 1)
                    bitcnt <= bitcnt + 1;
            end else begin
                state <= master_ack; bitcnt <= 0;
                sda_en <= 0;
            end
        end
        master_ack: begin
            if (pulse == 2 && count1 == 200)
                r_ack <= sda;
            if (count1 == clk_count1*4 - 1) begin
                ack_err <= (r_ack == 0);
                sda_en <= 0;
                state <= detect_stop;
            end
        end
        detect_stop: begin
            if (pulse == 2'b11 && count1 == 399) begin
                state <= idle;
                busy <= 0;
                done <= 1;
            end
        end
        default: state <= idle;
        endcase
    end
end
assign sda = (sda_en) ? sda_t : 1'bz;
endmodule
