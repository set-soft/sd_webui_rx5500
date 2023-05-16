#!/bin/sh
rm -f /etc/apt/apt.conf.d/docker-clean
echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache
chown root:root -R /var/cache/apt /var/lib/apt /root/.cache/pip /root/.cache/huggingface
chown _apt:root /var/cache/apt/archives/partial /var/lib/apt/lists/partial/ /var/lib/apt/lists/auxfiles/
bash
chown 1000:1000 -R /var/cache/apt /var/lib/apt /root/.cache/pip /root/.cache/huggingface
