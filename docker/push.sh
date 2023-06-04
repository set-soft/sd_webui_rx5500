#!/bin/bash
. env.sh
docker push setsoft/sd_webui:${TAG}
docker push setsoft/sd_webui:latest
