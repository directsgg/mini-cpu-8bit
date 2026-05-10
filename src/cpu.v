module cpu (
    input clk,
    input rst,
    input start_cpu,
    input stop_cpu,
    output run_cpu
);

    localparam 
        T0 = 3'd0, 
        T1 = 3'd1, 
        T2 = 3'd2, 
        T3 = 3'd3, 
        T4 = 3'd4;

    wire [3:0] B;
    wire [15:0] D;

    reg S;
    reg [2:0] SC;
    reg [3:0] PC;
    reg [3:0] AR;
    reg [7:0] IR;
    reg [7:0] DR;
    reg [7:0] AC;

    reg [7:0] mem [15:0];

    assign B = IR[3:0];

    decoder_4_16 op_decode (
        .a(IR[7]), 
        .b(IR[6]), 
        .c(IR[5]),
        .d(IR[4]),
        .D(D)
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            S <= 0;
            SC <= 0;
            PC <= 0;
            AR <= 0;
            IR <= 0;
            DR <= 0;
            AC <= 0;
        end else begin 
            S <= (start_cpu & ~S) | (~stop_cpu & S);
            if (S == 1'b0) begin
            end else begin
                if (
                    ( SC == T4 & D[0] == 1 & B[0] == 1)
                ) begin
                    SC <= 0;
                end else begin
                    SC <= SC + 1;
                end

                case (SC)
                    T0: begin
                        AR <= PC;
                    end
                    T1: begin
                        IR <= mem[AR];
                        PC <= PC + 1;
                    end
                    T2: begin
                        AR <= IR [3:0];
                    end
                    T4: begin
                        if (D[0] == 1 & B[0] == 1) begin
                            S <= 0;
                        end
                    end
                    default: begin
                    end
                endcase

            end
        end
    end

    assign run_cpu = S;

endmodule

module decoder_4_16 (
    input  a, b, c, d,
    output [15:0] D
);

    assign D[0] = ~a & ~b & ~c & ~d;
    assign D[1] = ~a & ~b & ~c &  d;
    assign D[2] = ~a & ~b &  c & ~d;
    assign D[3] = ~a & ~b &  c &  d;
    assign D[4] = ~a &  b & ~c & ~d;
    assign D[5] = ~a &  b & ~c &  d;
    assign D[6] = ~a &  b &  c & ~d;
    assign D[7] = ~a &  b &  c &  d;
    assign D[8] =  a & ~b & ~c & ~d;
    assign D[9] =  a & ~b & ~c &  d;
    assign D[10] =  a & ~b &  c & ~d;
    assign D[11] =  a & ~b &  c &  d;
    assign D[12] =  a &  b & ~c & ~d;
    assign D[13] =  a &  b & ~c &  d;
    assign D[14] =  a &  b &  c & ~d;
    assign D[15] =  a &  b &  c &  d;

endmodule