#!/bin/bash
sudo sed -i s/105/$RENDER_GID/ /etc/group
# Cache for huggingface, pip, etc. is /dockerx/cache
mkdir -p /dockerx/cache
mv ~/.cache  ~/.cache.no
ln -s /dockerx/cache ~/.cache
# All data goes to /dockerx/webui_data/
DATA=/dockerx/webui_data
SDWEBUI=/opt/stable-diffusion-webui
# Models
mkdir -p $DATA
echo "- Models in the persistent area"
cp -rna $SDWEBUI/models/ $DATA 2> $DATA/last_start.log
echo "- Control Net models in the persistent area"
cp -rna $SDWEBUI/extensions/sd-webui-controlnet/models/* $DATA/models/ControlNet/ 2>> $DATA/last_start.log
mv $SDWEBUI/extensions/sd-webui-controlnet/models $SDWEBUI/extensions/sd-webui-controlnet/models.default 2>> $DATA/last_start.log
ln -s $DATA/models/ControlNet $SDWEBUI/extensions/sd-webui-controlnet/models 2>> $DATA/last_start.log
ln -s $DATA/models/ControlNet $SDWEBUI/extensions/sd-webui-controlnet/annotator/downloads 2>> $DATA/last_start.log
echo "- Extensions in the persistent area"
cp -rna $SDWEBUI/extensions/ $DATA 2>> $DATA/last_start.log
echo "- Codeformer data copied to the persistent area with other models data"
mkdir -p $DATA/models/Codeformer 2>> $DATA/last_start.log
cp -rna $SDWEBUI/repositories/CodeFormer/weights/ $DATA/models/Codeformer 2>> $DATA/last_start.log
mv $SDWEBUI/repositories/CodeFormer/weights/ $SDWEBUI/repositories/CodeFormer/weights.default 2>> $DATA/last_start.log
ln -s $DATA/models/Codeformer/weights $SDWEBUI/repositories/CodeFormer/weights 2>> $DATA/last_start.log
echo "- Outputs in the persistent area"
mkdir -p $DATA/outputs 2>> $DATA/last_start.log
ln -s $DATA/outputs $SDWEBUI/outputs 2>> $DATA/last_start.log
echo "- Embeddings in the persistent area"
cp -rna $SDWEBUI/embeddings/ $DATA 2>> $DATA/last_start.log
mv $SDWEBUI/embeddings $SDWEBUI/embeddings.default 2>> $DATA/last_start.log
ln -s $DATA/embeddings $SDWEBUI/embeddings 2>> $DATA/last_start.log
echo "- Textual inversion templates in the persistent area"
cp -rna $SDWEBUI/textual_inversion_templates/ $DATA 2>> $DATA/last_start.log
mv $SDWEBUI/textual_inversion_templates $SDWEBUI/textual_inversion_templates.default 2>> $DATA/last_start.log
ln -s $DATA/textual_inversion_templates $SDWEBUI/textual_inversion_templates 2>> $DATA/last_start.log
echo "- Config states in the persistent area"
mkdir -p $DATA/config_states 2>> $DATA/last_start.log
ln -s $DATA/config_states $SDWEBUI/config_states 2>> $DATA/last_start.log
echo "- Additional networks models"
mv $DATA/extensions/sd-webui-additional-networks/models $DATA/extensions/sd-webui-additional-networks/models.default 2>> $DATA/last_start.log
ln -s $DATA/models $DATA/extensions/sd-webui-additional-networks/models 2>> $DATA/last_start.log
[ ! -L $DATA/models/lora ] && ln -s $DATA/models/Lora $DATA/models/lora 2>> $DATA/last_start.log
echo "- All persistent stuff owned by the current user"
sudo chown -R 1000:1000 $DATA 2>> $DATA/last_start.log
# The working directory is SD-webui repo
cd $SDWEBUI/

ARGS="$@"
sudo su -c "$ARGS" jenkins
