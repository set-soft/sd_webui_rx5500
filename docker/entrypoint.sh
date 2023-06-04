#!/bin/bash
sudo groupadd --gid $RENDER_GID render
sudo usermod -aG render $USERNAME
sudo usermod -aG video $USERNAME
# Cache for huggingface, pip, etc. is /dockerx/cache
mkdir -p /dockerx/cache
ln -s /dockerx/cache ~/.cache
# All data goes to /dockerx/webui_data/
DATA=/dockerx/webui_data/
SDWEBUI=/opt/stable-diffusion-webui
# Models
mkdir -p $DATA
echo "- Models in the persistent area"
cp -rna $SDWEBUI/models/ $DATA
echo "- Control Net models in the persistent area"
cp -rna $SDWEBUI/extensions/sd-webui-controlnet/models/* $DATA/models/ControlNet/
mv $SDWEBUI/extensions/sd-webui-controlnet/models $SDWEBUI/extensions/sd-webui-controlnet/models.default
ln -s $DATA/models/ControlNet $SDWEBUI/extensions/sd-webui-controlnet/models
ln -s $DATA/models/ControlNet $SDWEBUI/extensions/sd-webui-controlnet/annotator/downloads
echo "- Extensions in the persistent area"
cp -rna $SDWEBUI/extensions/ $DATA
echo "- Codeformer data copied to the persistent area with other models data"
mkdir -p $DATA/models/Codeformer
cp -rna $SDWEBUI/repositories/CodeFormer/weights/ $DATA/models/Codeformer
mv $SDWEBUI/repositories/CodeFormer/weights/ $SDWEBUI/repositories/CodeFormer/weights.default
ln -s $DATA/models/Codeformer/weights $SDWEBUI/repositories/CodeFormer/weights
echo "- Outputs in the persistent area"
mkdir -p $DATA/outputs
ln -s $DATA/outputs $SDWEBUI/outputs
echo "- Embeddings in the persistent area"
cp -rna $SDWEBUI/embeddings/ $DATA
mv $SDWEBUI/embeddings $SDWEBUI/embeddings.default
ln -s $DATA/embeddings $SDWEBUI/embeddings
echo "- Textual inversion templates in the persistent area"
cp -rna $SDWEBUI/textual_inversion_templates/ $DATA
mv $SDWEBUI/textual_inversion_templates $SDWEBUI/textual_inversion_templates.default
ln -s $DATA/textual_inversion_templates $SDWEBUI/textual_inversion_templates
echo "- Config states in the persistent area"
mkdir -p $DATA/config_states
ln -s $DATA/config_states $SDWEBUI/config_states
echo "- All persistent stuff owned by the current user"
sudo chown -R $USERNAME:$USERNAME $DATA
# The working directory is SD-webui repo
cd $SDWEBUI/

exec "$@"
