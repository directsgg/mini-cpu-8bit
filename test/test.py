# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge


@cocotb.test()
async def test_instruction_01(dut):
    dut._log.info("Test of instruction 0x01 (HALT)")

    # Generate clock(100MHz, period 10ns)
    clock = Clock(dut.clk, 10, unit="ns")
    cocotb.start_soon(clock.start())

    # Signal Initialization
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0  # rst = 1 (CPU high active, but rst_n is low)

    await ClockCycles(dut.clk, 2)  # Wait 20 cycles as in the testbench

    dut.rst_n.value = 1  # Remove reset (rst = 0)

    await ClockCycles(dut.clk, 1)

    # --- MEMORY PRELOAD ---
    # Load HALT instruction (0x01) at address 0
    dut.user_project.my_cpu.mem[0].value = 0x01

    dut._log.info("Preloaded memory: mem[0] = 0x01")

    # Start CPU
    dut._log.info("Starting CPU...")
    dut.uio_in.value = 0b00100000  # start_cpu (bit 5)
    await ClockCycles(dut.clk, 1)
    dut.uio_in.value = 0  # Clean start_cpu

    for _ in range(6):
        await RisingEdge(dut.clk)
        sc_val = dut.user_project.my_cpu.SC.value.to_unsigned()
        pc_val = dut.user_project.my_cpu.PC.value
        ar_val = dut.user_project.my_cpu.AR.value
        ir_val = dut.user_project.my_cpu.IR.value
        s_val = dut.user_project.my_cpu.S.value
        dut._log.info(f"Cycle T{sc_val} |  S: {s_val} | PC: {pc_val} | AR: {ar_val} | IR: {ir_val}")

    # Verifications
    assert dut.user_project.my_cpu.S.value == 0, "S should be 0 after HALT"
    assert (dut.uio_out.value.to_unsigned() & (1 << 7)) == 0, "run_cpu should be 0"

    dut._log.info("Test completed successfully")

    # Keep testing the module by changing the input values, waiting for
    # one or more clock cycles, and asserting the expected output values.
