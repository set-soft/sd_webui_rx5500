#!/bin/bash
. env.sh
docker buildx build -f Dockerfile --progress plain -t setsoft/rx5500_pt:${TAG} . 2>&1 | tee build.log
docker buildx build -f Dockerfile --progress plain -t setsoft/rx5500_pt:serhiin . 2>&1 | tee build.log
docker buildx build -f Dockerfile --progress plain -t setsoft/rx5500_pt:latest . 2>&1 | tee build.log
