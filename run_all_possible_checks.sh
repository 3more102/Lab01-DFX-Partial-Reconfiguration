#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"

echo "[CHECK] Required source files"
for f in \
  rtl/heartbeat_ctr.sv \
  rtl/pattern_chaser.sv \
  rtl/pattern_lfsr.sv \
  rtl/dfx_boundary_model.sv \
  tb/tb_dfx_behavior.sv \
  constr/leds.xdc \
  vitis/main.c \
  tcl/run_behavioral_sim.tcl \
  tcl/dfx_config_b_from_a.tcl \
  tcl/verify_and_write_bitstreams.tcl; do
  test -s "$ROOT/$f"
  echo "  OK $f"
done

if command -v iverilog >/dev/null 2>&1 && command -v vvp >/dev/null 2>&1; then
  echo "[CHECK] Icarus Verilog behavioral simulation"
  mkdir -p "$ROOT/sim/iverilog"
  iverilog -g2012 -Wall \
    -o "$ROOT/sim/iverilog/tb_dfx_behavior.vvp" \
    "$ROOT/rtl/heartbeat_ctr.sv" \
    "$ROOT/rtl/pattern_chaser.sv" \
    "$ROOT/rtl/pattern_lfsr.sv" \
    "$ROOT/rtl/dfx_boundary_model.sv" \
    "$ROOT/tb/tb_dfx_behavior.sv"
  vvp "$ROOT/sim/iverilog/tb_dfx_behavior.vvp" | tee "$ROOT/sim/iverilog/test.log"
  grep -F "[TB] Behavioral Verification Passed!" "$ROOT/sim/iverilog/test.log" >/dev/null
else
  echo "[SKIP] Icarus Verilog not installed"
fi

if command -v vivado >/dev/null 2>&1; then
  echo "[CHECK] Vivado found; running behavioral simulation"
  (cd "$ROOT" && vivado -mode batch -source tcl/run_behavioral_sim.tcl)
else
  echo "[SKIP] Vivado not installed in this environment"
fi
