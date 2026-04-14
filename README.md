# NVM Simulation

This repository extends [OMA-NVM/NVM_Simulation](https://github.com/OMA-NVM/NVM_Simulation.git) and uses gem5 plus NVMain for NVM simulation experiments.

## Setup

Initialize submodules after cloning:

```bash
git submodule init
git submodule update
```

## Docker Workflow

This project uses Docker in two different ways:

1. Host-side Docker is used to cross-compile the ARM64 workload binaries.
2. The `nvmsimulation` container is used to run `gem5.fast` and collect results.

The documented in-container repository root is `/NVMSimulation`.

## Build Required Workload Binaries

Before running the gem5 Python scripts, build the binaries they depend on.

The simplest way is:

```bash
./scripts/build_test_binaries.sh
```

This script builds all four required workload binaries:

| Root target | Python script | Required binary |
| --- | --- | --- |
| `make cim_ivf` | `simulator/gem5/scripts/run_cim_ivf.py` | `simulator/gem5/tests/test-progs/ivf_matching/bin/ivf_sim` |
| `make cim_verify` | `simulator/gem5/scripts/run_cim_verify.py` | `simulator/gem5/tests/test-progs/ivf_matching/verify_bin/ivf_verify` |
| `make nocim_ivf` | `simulator/gem5/scripts/run_nocim_ivf.py` | `simulator/gem5/tests/test-progs/ivf_nocim_matching/bin/pf_kernel_roi` |
| `make nocim_kdtree` | `simulator/gem5/scripts/run_nocim_kdtree.py` | `simulator/gem5/tests/test-progs/simulation_kdtree/bin/pf_kernel_roi` |

Equivalent manual commands:

```bash
make -C simulator/gem5/tests/test-progs/ivf_matching cim
make -C simulator/gem5/tests/test-progs/ivf_matching verify
make -C simulator/gem5/tests/test-progs/ivf_nocim_matching build
make -C simulator/gem5/tests/test-progs/simulation_kdtree build
```

Notes:

- These per-workload makefiles call `docker run` with `dockcross/linux-arm64`.
- Run the compile step in an environment where Docker is available.
- `make verify` also generates the verifier input data before building `ivf_verify`.

## Build The Runtime Image

Build the gem5 runtime image from the repository root:

```bash
docker build -t nvmsimulation .
```

The image build runs [`setup.sh`](setup.sh), which initializes submodules, prepares dataset directories, and builds `simulator/gem5/build/ARM/gem5.fast` with `CDNCcim=1`.

## Start The Runtime Container

Run the container with the repository mounted at `/NVMSimulation`:

```bash
docker run --rm -it \
  -v "$(pwd):/NVMSimulation" \
  -w /NVMSimulation \
  nvmsimulation
```

Using the bind mount keeps the container aligned with your current checkout and writes result files back to the host repository.

## Run The Pipeline

Inside the container, the root [`Makefile`](Makefile) runs the gem5 scripts and renames `m5out/stats.txt` to a target-specific file.

To generate all runtime results:

```bash
make all
make cim_verify
```

Equivalent explicit sequence:

```bash
make cim_ivf
make cim_verify
make nocim_ivf
make nocim_kdtree
```

Target meaning:

- `make cim_ivf`: runs the CIM-enabled IVF workload.
- `make cim_verify`: runs the verifier workload and checks whether the CIM result is correct.
- `make nocim_ivf`: runs the non-CIM IVF workload.
- `make nocim_kdtree`: runs the non-CIM KD-tree workload.

Optional shorter runs with a step limit:

```bash
make all 100
make cim_ivf 100
make nocim_ivf 100
make nocim_kdtree 100
```

## Output Files

After the runs complete, the result files are written to:

- `/NVMSimulation/simulator/gem5/m5out/cim_ivf.txt`
- `/NVMSimulation/simulator/gem5/m5out/cim_verify.txt`
- `/NVMSimulation/simulator/gem5/m5out/nocim_ivf.txt`
- `/NVMSimulation/simulator/gem5/m5out/nocim_kdtree.txt`

Each root `make` target also prints:

- average `simSeconds`
- maximum `simSeconds`

## End-To-End Example

From the host:

```bash
git submodule init
git submodule update
./scripts/build_test_binaries.sh
docker build -t nvmsimulation .
docker run --rm -it \
  -v "$(pwd):/NVMSimulation" \
  -w /NVMSimulation \
  nvmsimulation
```

Inside the container:

```bash
make all
make cim_verify
```
