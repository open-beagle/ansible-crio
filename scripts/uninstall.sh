#!/bin/sh

set -ex

systemctl stop docker.service
systemctl stop docker.socket
systemctl stop crio.service

systemctl disable docker.service
systemctl disable docker.socket
systemctl disable crio.service

# 卸载CRI-O服务
rm -rf /etc/systemd/system/crio.service /etc/systemd/system/docker.socket /etc/systemd/system/docker.service

# 卸载CRI-O
rm -rf /opt/bin/crio /opt/bin/pinns

# 卸载Docker
rm -rf /opt/bin/dockerd /opt/bin/docker-init /opt/bin/docker-proxy

# 卸载CRI-O插件
rm -rf /usr/libexec/crio/runc /usr/libexec/crio/crun /usr/libexec/crio/conmon /usr/libexec/crio/conmonrs

# 卸载Docker插件
rm -rf /usr/libexec/docker/cli-plugins/docker-buildx

# 卸载命令行工具
rm -rf /opt/bin/crictl /opt/bin/docker /opt/bin/dasel /opt/bin/yq
rm -rf /usr/local/bin/crictl /usr/local/bin/docker /usr/local/bin/dasel /usr/local/bin/yq

rm -rf /opt/crio/current