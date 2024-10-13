FROM setsoft/rx5500_pt:latest

RUN sudo ln -s /home/jenkins/.local/ /root/ &&\
    echo "Install Control Net deps" &&\
    sudo pip install mediapipe fvcore &&\
    cd /opt &&\
    sudo git clone --depth 1 https://github.com/AUTOMATIC1111/stable-diffusion-webui.git &&\
    cd stable-diffusion-webui/ &&\
    echo "Install Rust and Cargo to compile tokenizers" &&\
    sudo apt update &&\
    sudo apt install -y rustc cargo &&\
    export RUSTFLAGS="-A invalid_reference_casting" &&\
    echo "Install all WebUI deps" &&\
    sudo -E python launch.py --exit --skip-torch-cuda-test --skip-python-version-check  &&\
    echo "Control net dependencies" &&\
    sudo pip install svglib addict yapf albumentations==1.4.3 "timm<=0.9.5" "pydantic<=1.10.17" "controlnet_aux>=0.0.9" &&\
    echo "ADetailer dependencies" &&\
    sudo pip install ultralytics rich &&\
    echo "Clean-up the repos" &&\
    sudo chown 1000:1000 -R /opt/stable-diffusion-webui/ &&\
    chmod -R +w /opt/stable-diffusion-webui/repositories/*/.git &&\
    rm -r /opt/stable-diffusion-webui/repositories/*/.git &&\
    echo "Keep only one OpenCV, and without X11 support" &&\
    sudo pip uninstall -y opencv-contrib-python opencv-python &&\
    sudo pip install opencv-contrib-python-headless &&\
    echo "Cache clean-up" &&\
    sudo rm -r /root/.cache/pip &&\
    echo "Remove Rust and Cargo" &&\
    sudo apt remove -y rustc cargo &&\
    sudo rm -rf /var/cache/debconf/templates.dat-old /var/lib/dpkg/status-old

