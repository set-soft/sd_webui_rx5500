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
       --env=HSA_OVERRIDE_GFX_VERSION=10.3.0 \
       --env=LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libtcmalloc_minimal.so.4 \
       --group-add $RENDER_GID \
       --group-add=video \
       --ipc=host --cap-add=SYS_PTRACE --security-opt seccomp=unconfined \
       --device=/dev/kfd --device=/dev/dri \
       -v $DOCKERX:/dockerx \
       --network=host \
       rocm_torch:1.3.1_rocm5.2_bullseye \
       python /opt/stable-diffusion-webui/launch.py \
          --skip-install --skip-version-check \
          --data-dir /dockerx/webui_data \
          --precision full --no-half --medvram --opt-sub-quad-attention

#       --env=PYTORCH_CUDA_ALLOC_CONF=garbage_collection_threshold:0.6,max_split_size_mb:128 \
# python /opt/stable-diffusion-webui/launch.py --skip-install --skip-version-check --data-dir /dockerx/webui_data --precision full --no-half --medvram --opt-sub-quad-attention

#       --env=XDG_CACHE_HOME=/dockerx/ \
#       rocm_torch:1.3.1_rocm5.2_bullseye \
# Para cachear cosas de Debian
#       debian:bullseye-slim \

