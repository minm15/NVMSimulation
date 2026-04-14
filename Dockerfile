FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    m4 \
    scons \
    zlib1g \
    zlib1g-dev \
    libprotobuf-dev \
    protobuf-compiler \
    libprotoc-dev \
    libgoogle-perftools-dev \
    python3-dev \
    libboost-all-dev \
    libhdf5-serial-dev \
    pkg-config \
    python3-tk \
    clang-format-15 \
    vim \
    && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/clang-format clang-format /usr/bin/clang-format-15 150 \
        --slave /usr/bin/clang-format-diff clang-format-diff /usr/bin/clang-format-diff-15 \
        --slave /usr/bin/git-clang-format git-clang-format /usr/bin/git-clang-format-15

WORKDIR /NVMSimulation

COPY . .

RUN rm -rf /NVMSimulation/simulator/gem5/build \
    && chmod +x /NVMSimulation/setup.sh \
    && /NVMSimulation/setup.sh

CMD ["/bin/bash"]
