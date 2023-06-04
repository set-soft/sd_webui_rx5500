FROM debian:bullseye-slim

ENV USERNAME=rocm-user
ARG USER_UID=1000
ARG USER_GID=$USER_UID
ARG TORCH=1.13.1+rocm5.2
ARG TORCHV=0.14.1+rocm5.2
ARG TORCHA=0.13.1
ARG TORCHURL=https://download.pytorch.org/whl/rocm5.2
# This is to use cached files, otherwise you can leave empty
#ARG PIPOPS="--find-links=/root/.cache/pip --no-index"
ARG PIPOPS=""

RUN apt update &&\
    echo "Minimal OS support: Python & Git" &&\
    apt-get install -y --no-install-recommends sudo python3 pip python3-git libtcmalloc-minimal4 &&\
    echo "For compatibility make python command usable" &&\
    ln -s /usr/bin/python3 /usr/bin/python &&\
    echo "Remove Debian files we don't need" &&\
    rm -rf /var/cache/debconf/templates.dat-old /var/lib/dpkg/status-old

# Git configuration to be permisive
COPY gitconfig /etc

# The PyTorch and ROCm libs are the core of this image
# We install it first so the tools doesn't pull another version i.e. CUDA Torch
RUN echo "Installing PyTorch dependencies, to avoid getting them from PyTorch" && \
    pip install $PIPOPS requests numpy urllib3 certifi idna charset-normalizer &&\
    echo "Installing PyTorch and ROCm" &&\
    pip install $PIPOPS torch==$TORCH torchvision==$TORCHV torchaudio==$TORCHA --extra-index-url $TORCHURL &&\
    echo "Cache clean-up" &&\
    rm -r /root/.cache/pip
