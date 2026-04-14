#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
TEST_PROGS_DIR="${ROOT_DIR}/simulator/gem5/tests/test-progs"

build_target() {
    local dir="$1"
    local target="$2"
    local output="$3"

    echo "[build] ${dir} (${target})"
    make -C "${TEST_PROGS_DIR}/${dir}" "${target}"

    if [[ ! -x "${TEST_PROGS_DIR}/${output}" ]]; then
        echo "[error] expected binary not found or not executable: ${TEST_PROGS_DIR}/${output}" >&2
        exit 1
    fi

    echo "[ok] ${output}"
}

build_target "ivf_matching" "cim" "ivf_matching/bin/ivf_sim"
build_target "ivf_matching" "verify" "ivf_matching/verify_bin/ivf_verify"
build_target "ivf_nocim_matching" "build" "ivf_nocim_matching/bin/pf_kernel_roi"
build_target "simulation_kdtree" "build" "simulation_kdtree/bin/pf_kernel_roi"

echo "[done] all Makefile test-program binaries are up to date"
