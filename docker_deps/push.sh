#!/bin/bash
. env.sh
docker push setsoft/sd_webui_base:${TAG}
docker push setsoft/sd_webui_base:latest
