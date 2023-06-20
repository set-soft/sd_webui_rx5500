#!/bin/sh
echo "Removing unneeded tools (+10G disk space)"
# 8.6G + 690M + 655M + 301M = 10.25G
sudo rm -R /opt/hostedtoolcache /opt/microsoft /opt/az /opt/google
echo "Free disk:"
df -h
WODI=sd_webui_rx5500/sd_webui_rx5500
echo Script: /home/runner/work/$WODI/$2
chmod +x /home/runner/work/$WODI/$2
echo Docker image $1
docker pull $1
docker run --rm --workdir /__w/$WODI -e "HOME=/github/home" -e GITHUB_ACTIONS=true -e CI=true -v "/var/run/docker.sock":"/var/run/docker.sock" -v "/home/runner/work":"/__w" -v "/home/runner/runners/2.305.0/externals":"/__e":ro -v "/home/runner/work/_temp":"/__w/_temp" -v "/home/runner/work/_actions":"/__w/_actions" -v "/home/runner/work/_temp/_github_home":"/github/home" -v "/home/runner/work/_temp/_github_workflow":"/github/workflow" $1 /bin/sh -c /__w/$WODI/$2
