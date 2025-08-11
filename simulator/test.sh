#!/bin/bash


GEM5=gem5/build/ARM/gem5.fast
CFG=nvmain/Config/STTRAM_Everspin_4GB.config
BIN=./sttmram_test.arm

$GEM5 gem5/configs/deprecated/example/se.py \
  -c $BIN --options="67108864" \
  --cpu-type=TimingSimpleCPU \
  --mem-type=NVMainMemory \
  --nvmain-config=$CFG \
  --sys-clock=1GHz --cpu-clock=1GHz \
  --caches --l2cache \
  --l1d_size=32kB --l1i_size=32kB --l2_size=1MB


