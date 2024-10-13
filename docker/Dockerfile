FROM setsoft/sd_webui_base:latest

RUN echo "Install Control Net 1.1" &&\
    cd /opt/stable-diffusion-webui/extensions/ &&\
    sudo git clone --depth 1 https://github.com/Mikubill/sd-webui-controlnet.git &&\
    sudo chown 1000:1000 -R /opt/stable-diffusion-webui/ &&\
    chmod -R +w /opt/stable-diffusion-webui/extensions/*/.git &&\
    rm -r /opt/stable-diffusion-webui/extensions/*/.git

RUN echo "Install Ultimate Upscale" &&\
    cd /opt/stable-diffusion-webui/extensions/ &&\
    sudo git clone --depth 1 https://github.com/Coyote-A/ultimate-upscale-for-automatic1111.git &&\
    sudo chown 1000:1000 -R /opt/stable-diffusion-webui/ &&\
    chmod -R +w /opt/stable-diffusion-webui/extensions/*/.git &&\
    rm -r /opt/stable-diffusion-webui/extensions/*/.git

RUN echo "Install Regional Prompter" &&\
    cd /opt/stable-diffusion-webui/extensions/ &&\
    sudo git clone --depth 1 https://github.com/hako-mikan/sd-webui-regional-prompter.git &&\
    sudo chown 1000:1000 -R /opt/stable-diffusion-webui/ &&\
    chmod -R +w /opt/stable-diffusion-webui/extensions/*/.git &&\
    rm -r /opt/stable-diffusion-webui/extensions/*/.git

RUN echo "Install Additional Networks" &&\
    cd /opt/stable-diffusion-webui/extensions/ &&\
    sudo git clone --depth 1 https://github.com/kohya-ss/sd-webui-additional-networks.git &&\
    sudo chown 1000:1000 -R /opt/stable-diffusion-webui/ &&\
    chmod -R +w /opt/stable-diffusion-webui/extensions/*/.git &&\
    rm -r /opt/stable-diffusion-webui/extensions/*/.git

RUN echo "Install LyCORIS" &&\
    cd /opt/stable-diffusion-webui/extensions/ &&\
    sudo git clone --depth 1 https://github.com/KohakuBlueleaf/a1111-sd-webui-lycoris.git &&\
    sudo chown 1000:1000 -R /opt/stable-diffusion-webui/ &&\
    chmod -R +w /opt/stable-diffusion-webui/extensions/*/.git &&\
    rm -r /opt/stable-diffusion-webui/extensions/*/.git

RUN echo "Install ADetailer" &&\
    cd /opt/stable-diffusion-webui/extensions/ &&\
    sudo git clone --depth 1 https://github.com/Bing-su/adetailer &&\
    sudo chown 1000:1000 -R /opt/stable-diffusion-webui/ &&\
    chmod -R +w /opt/stable-diffusion-webui/extensions/*/.git &&\
    rm -r /opt/stable-diffusion-webui/extensions/*/.git

RUN echo "Install Dynamic Thresholding" &&\
    cd /opt/stable-diffusion-webui/extensions/ &&\
    sudo git clone --depth 1 https://github.com/mcmonkeyprojects/sd-dynamic-thresholding &&\
    sudo chown 1000:1000 -R /opt/stable-diffusion-webui/ &&\
    chmod -R +w /opt/stable-diffusion-webui/extensions/*/.git &&\
    rm -r /opt/stable-diffusion-webui/extensions/*/.git

# Setup what we do when the image is started
COPY entrypoint.sh /tmp
RUN sudo chmod 777 /tmp/entrypoint.sh
ENTRYPOINT ["/tmp/entrypoint.sh"]

# The user we will use when the image is started
# USER $USERNAME

# We run the entrypoint using bash as command if none specified
CMD ["/bin/bash"]
