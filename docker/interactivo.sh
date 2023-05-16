export RENDER_GID=$(getent group render | cut -d: -f3)
docker run -it --rm --user 0:0 \
       -e RENDER_GID \
       --env=HSA_OVERRIDE_GFX_VERSION=10.3.0 \
       --env=PYTORCH_CUDA_ALLOC_CONF=garbage_collection_threshold:0.6,max_split_size_mb:128 \
       --env=LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libtcmalloc_minimal.so.4 \
       --group-add $RENDER_GID \
       --group-add=video \
       --ipc=host --cap-add=SYS_PTRACE --security-opt seccomp=unconfined \
       --device=/dev/kfd --device=/dev/dri \
       -v $(pwd)/apt_debs:/var/cache/apt:rw \
       -v $(pwd)/apt_files:/var/lib/apt:rw \
       -v $(pwd)/pip:/root/.cache/pip:rw \
       -v $(pwd)/huggingface:/root/.cache/huggingface:rw \
       -v $(pwd)/persistent.sh:/persistent.sh \
       -v /mnt/sdb5/dockerx:/dockerx \
       --network=host \
       rocm_torch:1.3.1_rocm5.2_bullseye \
       /persistent.sh

#       --env=XDG_CACHE_HOME=/dockerx/ \
#       rocm_torch:1.3.1_rocm5.2_bullseye \
# Para cachear cosas de Debian
#       debian:bullseye-slim \

