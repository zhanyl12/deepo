# ==================================================================
# module list
# ------------------------------------------------------------------
# darknet       latest (git)
# python        3.6    (apt)
# torch         latest (git)
# chainer       latest (pip)
# jupyter       latest (pip)
# mxnet         latest (pip)
# onnx          latest (pip)
# paddle        latest (pip)
# pytorch       latest (pip)
# tensorflow    latest (pip)
# theano        latest (git)
# jupyterlab    latest (pip)
# keras         latest (pip)
# lasagne       latest (git)
# opencv        4.3.0  (git)
# sonnet        latest (pip)
# caffe         latest (git)
# cntk          latest (pip)
# ==================================================================

FROM nvidia/cuda:10.1-cudnn7-devel-ubuntu18.04
ENV LANG C.UTF-8
RUN APT_INSTALL="apt-get install -y --no-install-recommends" && \
    PIP_INSTALL="python -m pip --no-cache-dir install --upgrade" && \
    GIT_CLONE="git clone --depth 10" && \

    rm -rf /var/lib/apt/lists/* \
           /etc/apt/sources.list.d/cuda.list \
           /etc/apt/sources.list.d/nvidia-ml.list && \

    apt-get update && \

# ==================================================================
# tools
# ------------------------------------------------------------------

    DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
        build-essential \
        apt-utils \
        ca-certificates \
        wget \
        git \
        vim \
        libssl-dev \
        curl \
        unzip \
        unrar \
        && \

    $GIT_CLONE https://github.com/Kitware/CMake ~/cmake && \
    cd ~/cmake && \
    ./bootstrap && \
    make -j"$(nproc)" install && \

# ==================================================================
# python
# ------------------------------------------------------------------

    DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
        software-properties-common \
        && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
        python3.6 \
        python3.6-dev \
        python3-distutils-extra \
        && \
    wget -O ~/get-pip.py \
        https://bootstrap.pypa.io/get-pip.py && \
    python3.6 ~/get-pip.py && \
    ln -s /usr/bin/python3.6 /usr/local/bin/python3 && \
    ln -s /usr/bin/python3.6 /usr/local/bin/python && \
    $PIP_INSTALL \
        setuptools \
        && \
    $PIP_INSTALL \
        numpy \
        scipy \
        pandas \
        cloudpickle \
        scikit-image>=0.14.2 \
        scikit-learn \
        matplotlib \
        Cython \
        tqdm \
        && \

# ==================================================================
# torch
# ------------------------------------------------------------------

    DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
        sudo \
        && \

    $GIT_CLONE https://github.com/nagadomi/distro.git ~/torch --recursive && \
    cd ~/torch && \
    bash install-deps && \
    sed -i 's/${THIS_DIR}\/install/\/usr\/local/g' ./install.sh && \
    ./install.sh && \

# ==================================================================
# boost
# ------------------------------------------------------------------

    DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
        libboost-all-dev \
        && \

# ==================================================================
# jupyter
# ------------------------------------------------------------------

    $PIP_INSTALL \
        jupyter \
        && \

# ==================================================================
# pytorch
# ------------------------------------------------------------------

    $PIP_INSTALL \
        future \
        numpy \
        protobuf \
        enum34 \
        pyyaml \
        typing \
        && \
    $PIP_INSTALL \
        --pre torch torchvision -f \
        https://download.pytorch.org/whl/nightly/cu101/torch_nightly.html \
        && \

# ==================================================================
# tensorflow
# ------------------------------------------------------------------

    $PIP_INSTALL \
        tensorflow-gpu==1.15 \
        && \

# ==================================================================

# jupyterlab
# ------------------------------------------------------------------

    $PIP_INSTALL \
        jupyterlab \
        && \

# ==================================================================
# keras
# ------------------------------------------------------------------

    $PIP_INSTALL \
        h5py \
        keras \
        && \

# ==================================================================

# ==================================================================
# config & cleanup
# ------------------------------------------------------------------

    ldconfig && \
    apt-get clean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/* /tmp/* ~/*

EXPOSE 8888 6006
