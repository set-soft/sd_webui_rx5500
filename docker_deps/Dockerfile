FROM setsoft/rx5500_pt:latest

ENV USERNAME=rocm-user
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN cd /opt &&\
    git clone --depth 1 https://github.com/AUTOMATIC1111/stable-diffusion-webui.git &&\
    cd stable-diffusion-webui/ &&\
    echo "Install all WebUI deps" &&\
    python launch.py --exit --skip-torch-cuda-test &&\
    echo "Install Control Net deps" &&\
    pip install mediapipe fvcore &&\
    echo "Clean-up the repos" &&\
    chmod -R +w /opt/stable-diffusion-webui/repositories/*/.git &&\
    rm -r /opt/stable-diffusion-webui/repositories/*/.git &&\
    echo "Keep only one OpenCV, and without X11 support" &&\
    pip uninstall -y opencv-contrib-python opencv-python &&\
    pip install opencv-contrib-python-headless &&\
    echo "Cache clean-up" &&\
    rm -r /root/.cache/pip &&\
    chown $USER_UID:$USER_GID -R /opt/stable-diffusion-webui/

