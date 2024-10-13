FROM serhiin/rocm_gfx1012_pytorch:ubuntu2204_rocm543_pytorch22_py213

RUN sudo apt update &&\
    echo "libtcmalloc" &&\
    sudo apt-get install -y --no-install-recommends libtcmalloc-minimal4 &&\
    echo "Remove Debian files we don't need" &&\
    sudo rm -rf /var/cache/debconf/templates.dat-old /var/lib/dpkg/status-old

# Git configuration to be permisive
COPY gitconfig /etc

RUN echo "Git for python" && \
    sudo pip install GitPython &&\
    echo "Cache clean-up" &&\
    sudo rm -r /root/.cache/pip

ENTRYPOINT ["/bin/bash"]
