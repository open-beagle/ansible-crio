#!/bin/sh

set -ex

systemctl stop docker.service
systemctl stop docker.socket
systemctl stop containerd.service

systemctl disable docker.service
systemctl disable docker.socket
systemctl disable containerd.service

rm -rf /etc/systemd/system/containerd.service /etc/systemd/system/docker.socket /etc/systemd/system/docker.service

rm -rf /usr/local/bin/docker /usr/local/bin/dockerd /usr/local/bin/docker-init /usr/local/bin/docker-proxy /usr/libexec/docker/cli-plugins/docker-buildx
rm -rf /usr/local/bin/nerdctl /usr/local/bin/ctr /usr/local/bin/containerd /usr/local/bin/containerd-shim /usr/local/bin/containerd-stress /usr/local/bin/containerd-shim-runc-v1 /usr/local/bin/containerd-shim-runc-v2
rm -rf /usr/local/bin/runc

rm -rf /usr/bin/docker /usr/bin/dockerd /usr/bin/docker-init /usr/bin/docker-proxy
rm -rf /usr/bin/nerdctl /usr/bin/ctr /usr/bin/containerd /usr/bin/containerd-shim /usr/local/bin/containerd-stress /usr/bin/containerd-shim-runc-v1 /usr/bin/containerd-shim-runc-v2
rm -rf /usr/bin/runc

rm -rf /opt/bin/docker /opt/bin/dockerd /opt/bin/docker-init /opt/bin/docker-proxy
rm -rf /opt/bin/nerdctl /opt/bin/ctr /opt/bin/containerd /opt/bin/containerd-shim /usr/local/bin/containerd-stress /opt/bin/containerd-shim-runc-v1 /opt/bin/containerd-shim-runc-v2
rm -rf /opt/bin/runc