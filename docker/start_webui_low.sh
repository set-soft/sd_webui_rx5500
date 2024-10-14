set -e
export DOCKERX=$HOME/dockerx
export RENDER_GID=$(getent group render | cut -d: -f3)
echo "Setting up the working directory ($DOCKERX)"
[ ! -r $DOCKERX ] || [ ! -w $DOCKERX  ] && echo "No R/W $DOCKERX" && exit 1
mkdir -p $DOCKERX/cache
[ ! -r $DOCKERX/cache ] || [ ! -w $DOCKERX/cache  ] && echo "No R/W $DOCKERX/cache" && exit 1
mkdir -p $DOCKERX/webui_data
[ ! -r $DOCKERX/webui_data ] || [ ! -w $DOCKERX/webui_data  ] && echo "No R/W $DOCKERX/webui_data" && exit 1
docker run -it --rm \
       --name stable_diffusion_webui \
       -e RENDER_GID \
       --env=LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libtcmalloc_minimal.so.4 \
       --env=PYTORCH_HIP_ALLOC_CONF=garbage_collection_threshold:0.6,max_split_size_mb:128 \
       --env=PYTORCH_CUDA_ALLOC_CONF=garbage_collection_threshold:0.6,max_split_size_mb:128 \
       --ipc=host --cap-add=SYS_PTRACE --security-opt seccomp=unconfined \
       --device=/dev/kfd --device=/dev/dri \
       -v $DOCKERX:/dockerx \
       --network=host \
       setsoft/sd_webui:latest \
       python /opt/stable-diffusion-webui/launch.py \
          --skip-install --skip-version-check --skip-prepare-environment \
          --data-dir /dockerx/webui_data --theme dark \
          --lowvram --opt-sub-quad-attention

