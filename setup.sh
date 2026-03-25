#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GEM5_DIR="$ROOT_DIR/simulator/gem5"
EXPORT_ROOT="$GEM5_DIR/tests/test-progs/export_gem5"
IVF_SOURCE="$HOME/nas/homes/kaiii_data/export_gem5_dir/export_gem5_512_8/2013-01-10"
KDTREE_SOURCE="$HOME/nas/homes/kaiii_data/export_gem5/2013-01-10"
IVF_TARGET="$EXPORT_ROOT/ivf_matching/2013-01-10"
KDTREE_TARGET="$EXPORT_ROOT/kdtree_matching/2013-01-10"
TESTDATA_TARGET="$EXPORT_ROOT/test_data"
VERIFY_SOURCE="$GEM5_DIR/tests/test-progs/ivf_matching/test"

prepare_dataset_dir() {
    local source_dir="$1"
    local target_dir="$2"
    local label="$3"

    mkdir -p "$target_dir"

    if [ -d "$source_dir" ]; then
        echo "Syncing $label dataset from $source_dir"
        cp -a "$source_dir"/. "$target_dir"/
    else
        echo "Warning: $label dataset source not found at $source_dir" >&2
        echo "Warning: expected runtime data under $target_dir" >&2
    fi
}

if ! command -v scons >/dev/null 2>&1; then
    echo "Error: scons is not installed or not in PATH." >&2
    exit 1
fi

if [ ! -d "$GEM5_DIR" ]; then
    echo "Error: expected gem5 directory at $GEM5_DIR" >&2
    exit 1
fi

echo "Initializing git submodules..."
git -C "$ROOT_DIR" submodule init
git -C "$ROOT_DIR" submodule update

echo "Checking out gem5 final branch..."
if git -C "$GEM5_DIR" show-ref --verify --quiet refs/heads/final; then
    git -C "$GEM5_DIR" checkout final
elif git -C "$GEM5_DIR" show-ref --verify --quiet refs/remotes/origin/final; then
    git -C "$GEM5_DIR" checkout -B final origin/final
else
    echo "Error: gem5 final branch not found." >&2
    exit 1
fi

echo "Preparing local dataset directories..."
mkdir -p "$EXPORT_ROOT/ivf_matching" "$EXPORT_ROOT/kdtree_matching" "$TESTDATA_TARGET"
prepare_dataset_dir "$IVF_SOURCE" "$IVF_TARGET" "ivf_matching"
prepare_dataset_dir "$KDTREE_SOURCE" "$KDTREE_TARGET" "kdtree_matching"
if [ -d "$VERIFY_SOURCE" ]; then
    echo "Syncing verifier test data from $VERIFY_SOURCE"
    mkdir -p "$TESTDATA_TARGET"
    cp -a "$VERIFY_SOURCE"/. "$TESTDATA_TARGET"/
else
    echo "Warning: verifier test data source not found at $VERIFY_SOURCE" >&2
fi

echo "Building gem5.fast with CDNCcim enabled..."
cd "$GEM5_DIR"
python3 "$(command -v scons)" CDNCcim=1 -j 16 EXTRAS=../nvmain ./build/ARM/gem5.fast
