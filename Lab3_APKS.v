module Lab3_APKS #(
    parameter input_clk_freq = 50000000, 
    parameter i2c_freq       = 100000    
)(
    input  wire       clk,
    input  wire       reset_n,
    input  wire       start,
    input  wire [6:0] addr,
    input  wire       rw,          
    input  wire [7:0] data_in,
    output reg  [7:0] data_out,
    output reg        scl,
    inout  wire       sda,
    output reg        busy,
    output reg        ack_error
);

    localparam clk_divider = input_clk_freq / (i2c_freq * 4);

    reg [31:0] clk_cnt;
    reg        scl_clk;
    
    // Стани FSM
    localparam IDLE      = 3'b000;
    localparam START     = 3'b001;
    localparam ADDR_RW   = 3'b010;
    localparam ACK_ADDR  = 3'b011;
    localparam DATA_WR   = 3'b100;
    localparam ACK_DATA  = 3'b101;
    localparam STOP      = 3'b110;

    reg [2:0] state, next_state;
    reg [2:0] bit_cnt;
    reg [7:0] shift_reg;
    reg       sda_out;
    reg       sda_dir; 

    assign sda = (sda_dir) ? sda_out : 1'bz;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            clk_cnt <= 0;
            scl_clk <= 0;
        end else if (clk_cnt == clk_divider - 1) begin
            clk_cnt <= 0;
            scl_clk <= ~scl_clk;
        end else begin
            clk_cnt <= clk_cnt + 1;
        end
    end

    always @(posedge scl_clk or negedge reset_n) begin
        if (!reset_n) begin
            state     <= IDLE;
            scl       <= 1'b1;
            sda_out   <= 1'b1;
            sda_dir   <= 1'b1;
            busy      <= 1'b0;
            ack_error <= 1'b0;
            bit_cnt   <= 3'd7;
        end else begin
            case (state)
                IDLE: begin
                    scl       <= 1'b1;
                    sda_out   <= 1'b1;
                    sda_dir   <= 1'b1;
                    busy      <= 1'b0;
                    if (start) begin
                        busy      <= 1'b1;
                        shift_reg <= {addr, rw};
                        state     <= START;
                    end
                end

                START: begin
                    sda_out <= 1'b0; 
                    state   <= ADDR_RW;
                    bit_cnt <= 3'd7;
                end

                ADDR_RW: begin
                    scl     <= 1'b0;
                    sda_out <= shift_reg[bit_cnt];
                    scl     <= 1'b1;
                    if (bit_cnt == 0)
                        state <= ACK_ADDR;
                    else
                        bit_cnt <= bit_cnt - 1;
                end

                ACK_ADDR: begin
                    scl     <= 1'b0;
                    sda_dir <= 1'b0; 
                    scl     <= 1'b1;
                    ack_error <= sda; 
                    state     <= DATA_WR;
                    shift_reg <= data_in;
                    bit_cnt   <= 3'd7;
                end

                DATA_WR: begin
                    scl     <= 1'b0;
                    sda_dir <= 1'b1;
                    sda_out <= shift_reg[bit_cnt];
                    scl     <= 1'b1;
                    if (bit_cnt == 0)
                        state <= ACK_DATA;
                    else
                        bit_cnt <= bit_cnt - 1;
                end

                ACK_DATA: begin
                    scl     <= 1'b0;
                    sda_dir <= 1'b0;
                    scl     <= 1'b1;
                    state   <= STOP;
                end

                STOP: begin
                    scl     <= 1'b0;
                    sda_dir <= 1'b1;
                    sda_out <= 1'b0;
                    scl     <= 1'b1;
                    sda_out <= 1'b1; 
                    state   <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end
endmodule