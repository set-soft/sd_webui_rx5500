#!/bin/bash
. env.sh
docker buildx build -f Dockerfile --progress plain -t setsoft/sd_webui_base:${TAG} . 2>&1 | tee build.log
docker buildx build -f Dockerfile --progress plain -t setsoft/sd_webui_base:serhiin . 2>&1 | tee build.log
docker buildx build -f Dockerfile --progress plain -t setsoft/sd_webui_base:latest . 2>&1 | tee build.log
