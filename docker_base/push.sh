#!/bin/bash
. env.sh
docker push setsoft/rx5500_pt:${TAG}
docker push setsoft/rx5500_pt:latest
