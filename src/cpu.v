module cpu (
    input clk,
    input rst,
    input start_cpu,
    input stop_cpu,
    output run_cpu
);

    reg S;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            S <= 0;
        end else begin 
            S <= (start_cpu & ~S) | (~stop_cpu & S);
        end
    end

    assign run_cpu = S;

endmodule