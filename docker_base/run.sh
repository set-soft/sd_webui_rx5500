export RENDER_GID=$(getent group render | cut -d: -f3)
docker run -it --user 0:0 \
       -e RENDER_GID \
       --env=PYTORCH_CUDA_ALLOC_CONF=garbage_collection_threshold:0.6,max_split_size_mb:128 \
       --env=PYTORCH_HIP_ALLOC_CONF=garbage_collection_threshold:0.6,max_split_size_mb:128 \
       --ipc=host --cap-add=SYS_PTRACE --security-opt seccomp=unconfined \
       --device=/dev/kfd --device=/dev/dri \
       -v $HOME/dockerx:/dockerx \
       --network=host \
       docker.io/setsoft/rx5500_pt:latest
