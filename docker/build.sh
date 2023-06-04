#!/bin/bash
. env.sh
docker buildx build -f Dockerfile --progress plain -t setsoft/sd_webui:${TAG} . 2>&1 | tee build.log
docker buildx build -f Dockerfile --progress plain -t setsoft/sd_webui:latest . 2>&1 | tee build.log
