# NVM Simulation

This repository is **extended from** the original project:  
[OMA-NVM/NVM_Simulation](https://github.com/OMA-NVM/NVM_Simulation.git)  

It integrates **gem5** and **NVMain** for NVM-related simulation experiments, with additional modifications for specific use cases.

## Prerequisites

Before building this project, please follow the gem5 official guide to install all required dependencies:  
[official website](https://www.gem5.org/documentation/general_docs/building)  

## Setup
After cloning the repository, obtain the submodule by the following command
```bash
git submodule init
git submodule update
```

## Build Instructions

Note that the original project provides the choice to select the additional function for compute-in-memory functionality by change
the example script 

```bash
PYTHON_CONFIG=/usr/bin/python3.10-config \
LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH \
python3 `which scons` -j 8 EXTRAS=../nvmain ./build/ARM/gem5.fast
```

to

```bash
PYTHON_CONFIG=/usr/bin/python3.10-config \
LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH \
python3 `which scons` CDNCcim=1 -j 8 EXTRAS=../nvmain ./build/ARM/gem5.fast
```

The original project indicates it currently supports the following features: \
bitflip: Bit-Flip Trace Writer \
CDNCcim: Compute in Memory module for NVM technologies \
hybrid_cache: Heterogeneous cache extension

## Test Run
After successful compilation, you can test the build using a simple Hello World script:
```bash
./build/ARM/gem5.fast hello-world.py
```
