#!/bin/bash
sudo groupadd --gid $RENDER_GID render
sudo usermod -aG render $USERNAME
sudo usermod -aG video $USERNAME
# Cache for huggingface, pip, etc. is /dockerx/cache
mkdir -p /dockerx/cache
ln -s /dockerx/cache ~/.cache
# All data goes to /dockerx/webui_data/
DATA=/dockerx/webui_data/
# Models
mkdir -p $DATA
cp -rna /opt/stable-diffusion-webui/models/ $DATA
cp -rna /opt/stable-diffusion-webui/extensions/ $DATA
mkdir -p $DATA/models/Codeformer
cp -rna /opt/stable-diffusion-webui/repositories/CodeFormer/weights/ $DATA/models/Codeformer
mv /opt/stable-diffusion-webui/repositories/CodeFormer/weights/ /opt/stable-diffusion-webui/repositories/CodeFormer/weights.default
ln -s $DATA/models/Codeformer/weights /opt/stable-diffusion-webui/repositories/CodeFormer/weights
mkdir -p $DATA/outputs
ln -s $DATA/outputs /opt/stable-diffusion-webui/outputs
sudo chown -R $USERNAME:$USERNAME $DATA
# The working directory is SD-webui repo
cd /opt/stable-diffusion-webui/

exec "$@"
