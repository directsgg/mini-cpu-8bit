/*
 * Copyright (c) 2024 Jorge Gutierrez
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_directsgg_mini_cpu_8bit (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  wire rst, start_cpu, stop_cpu, run_cpu;
  assign rst = ~rst_n;
  // All output pins must be assigned. If not used, assign to 0.
  assign uo_out  = ui_in + uio_in;  // Example: ou_out is the sum of ui_in and uio_in
  assign uio_out[6:0] = 0;
  assign uio_oe = 8'b10000000;
  assign start_cpu = uio_in[5];
  assign stop_cpu = uio_in[6];
  assign uio_out[7] = run_cpu;

  cpu my_cpu (
      .clk(clk),
      .rst(rst),
      .start_cpu(start_cpu),
      .stop_cpu(stop_cpu),
      .run_cpu(run_cpu)
  );

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, 1'b0};

endmodule
