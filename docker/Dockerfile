FROM debian:bullseye-slim

ENV USERNAME=rocm-user
ENV REQS_FILE=requirements.txt
ARG USER_UID=1000
ARG USER_GID=$USER_UID
ARG TORCH=1.13.1+rocm5.2
ARG TORCHV=0.14.1+rocm5.2
ARG TORCHA=0.13.1
ARG TORCHURL=https://download.pytorch.org/whl/rocm5.2
# This is to use cached files, otherwise you can leave empty
#ARG PIPOPS="--find-links=/root/.cache/pip --no-index"
ARG PIPOPS=""

# Avoid removing the cached packages
RUN rm -f /etc/apt/apt.conf.d/docker-clean; echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache

RUN --mount=type=cache,id=apt_debs,target=/var/cache/apt \
    --mount=type=cache,id=apt_files,target=/var/lib/apt \
    apt update &&\
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
RUN --mount=type=cache,target=/root/.cache/pip,id=pip \
    pip cache info &&\
    echo "Installing PyTorch dependencies, to avoid getting them from PyTorch" && \
    pip install $PIPOPS requests numpy urllib3 certifi idna charset-normalizer &&\
    echo "Installing PyTorch and ROCm" &&\
    pip install $PIPOPS torch==$TORCH torchvision==$TORCHV torchaudio==$TORCHA --extra-index-url $TORCHURL

RUN --mount=type=cache,target=/root/.cache/pip,id=pip \
    --mount=type=cache,target=/root/.cache/huggingface,id=huggingface \
    pip cache info &&\
    cd /opt &&\
    git clone --depth 1 https://github.com/AUTOMATIC1111/stable-diffusion-webui.git &&\
    cd stable-diffusion-webui/ &&\
    echo "Install all WebUI deps" &&\
    python launch.py --exit --skip-torch-cuda-test &&\
    echo "Install Control Net deps" &&\
    pip install mediapipe fvcore &&\
    echo "Install Control Net repo" &&\
    cd /opt/stable-diffusion-webui/extensions/ &&\
    git clone --depth 1 https://github.com/Mikubill/sd-webui-controlnet.git &&\
    echo "Clean-up the repos" &&\
    chmod -R +w /opt/stable-diffusion-webui/repositories/*/.git &&\
    rm -r /opt/stable-diffusion-webui/repositories/*/.git &&\
    echo "Keep only one OpenCV, and without X11 support" &&\
    pip uninstall -y opencv-contrib-python opencv-python &&\
    pip install opencv-contrib-python-headless &&\
    chown $USER_UID:$USER_GID -R /opt/stable-diffusion-webui/

# This layer creates the user and makes it easy to go root using sudo (no password)
RUN groupadd --gid $USER_GID $USERNAME &&\
    useradd --uid $USER_UID --gid $USER_GID -m $USERNAME &&\
    echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME &&\
    chmod 0440 /etc/sudoers.d/$USERNAME

# Setup what we do when the image is started
COPY entrypoint.sh /tmp
RUN chmod 777 /tmp/entrypoint.sh
ENTRYPOINT ["/tmp/entrypoint.sh"]

# The user we will use when the image is started
USER $USERNAME

# We run the entrypoint using bash as command if none specified
CMD ["/bin/bash"]
