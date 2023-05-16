#!/bin/bash
TAG=sd1.2.1_pt1.13.1_rocm5.2_d11.7
docker push setsoft/sd_webui:${TAG}
docker push setsoft/sd_webui:latest
