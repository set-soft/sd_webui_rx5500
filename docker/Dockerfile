FROM setsoft/sd_webui_base:latest

ENV USERNAME=rocm-user
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN echo "Install Control Net repo" &&\
    cd /opt/stable-diffusion-webui/extensions/ &&\
    git clone --depth 1 https://github.com/Mikubill/sd-webui-controlnet.git &&\
    git clone --depth 1 https://github.com/Coyote-A/ultimate-upscale-for-automatic1111.git &&\
    git clone --depth 1 https://github.com/hako-mikan/sd-webui-regional-prompter.git &&\
    git clone --depth 1 https://github.com/kohya-ss/sd-webui-additional-networks.git &&\
    git clone --depth 1 https://github.com/KohakuBlueleaf/a1111-sd-webui-lycoris.git &&\
    echo "Clean-up the repos" &&\
    chmod -R +w /opt/stable-diffusion-webui/extensions/*/.git &&\
    rm -r /opt/stable-diffusion-webui/extensions/*/.git &&\
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
