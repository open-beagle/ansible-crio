#!/bin/sh

export PATH=/usr/sbin:$PATH

set -ex

# CRI-O架构
BUILD_ARCH="${BUILD_ARCH:-amd64}"
# CRI-O版本
BUILD_VERSION="${BUILD_VERSION:-v1.30.8}"

LOCAL_ARCH=$(uname -m)
if [ "$LOCAL_ARCH" = "x86_64" ]; then
  BUILD_ARCH="amd64"
elif [ "$(echo $LOCAL_ARCH | head -c 5)" = "armv8" ]; then
  BUILD_ARCH="arm64"
elif [ "$LOCAL_ARCH" = "aarch64" ]; then
  BUILD_ARCH="arm64"
elif [ "$LOCAL_ARCH" = "loongarch64" ]; then
  BUILD_ARCH="loong64"
else
  BUILD_ARCH="unsupported"
fi
if [ "$LOCAL_ARCH" = "unsupported" ]; then
  echo "This system's architecture ${LOCAL_ARCH} isn't supported"
  exit 0
fi

mkdir -p /opt/bin /opt/cni

# 安装bin/crio
if [ -L "/opt/crio/current" ] && [ "$(readlink -f "/opt/crio/current")" = "/opt/crio/${BUILD_VERSION}" ]; then
  echo "版本${BUILD_VERSION}，系统已安装，如若需要更新请先卸载。"
  exit 0
else
  rm -rf /opt/crio/current
  ln -s /opt/crio/${BUILD_VERSION} /opt/crio/current
fi

# 安装crio
rm -rf /opt/bin/crio /opt/bin/pinns
ln -s /opt/crio/${BUILD_VERSION}/bin/crio /opt/bin/crio
ln -s /opt/crio/${BUILD_VERSION}/bin/pinns /opt/bin/pinns

# 安装docker
rm -rf /opt/bin/dockerd /opt/bin/docker-init /opt/bin/docker-proxy
ln -s /opt/crio/${BUILD_VERSION}/bin/dockerd /opt/bin/dockerd
ln -s /opt/crio/${BUILD_VERSION}/bin/docker-init /opt/bin/docker-init
ln -s /opt/crio/${BUILD_VERSION}/bin/docker-proxy /opt/bin/docker-proxy

# 安装crio插件-runc crun conmon conmonrs
rm -rf /usr/libexec/crio/runc /usr/libexec/crio/crun /usr/libexec/crio/conmon /usr/libexec/crio/conmonrs
mkdir -p /usr/libexec/crio
ln -s /opt/crio/${BUILD_VERSION}/bin/runc /usr/libexec/crio/runc
ln -s /opt/crio/${BUILD_VERSION}/bin/crun /usr/libexec/crio/crun
ln -s /opt/crio/${BUILD_VERSION}/bin/conmon /usr/libexec/crio/conmon
ln -s /opt/crio/${BUILD_VERSION}/bin/conmonrs /usr/libexec/crio/conmonrs

# 安装docker插件-docker-buildx
rm -rf /usr/libexec/docker/cli-plugins/docker-buildx
mkdir -p /usr/libexec/docker/cli-plugins
ln -s /opt/crio/${BUILD_VERSION}/bin/docker-buildx /usr/libexec/docker/cli-plugins/docker-buildx

# 将 crictl docker 命令安装至全局
rm -rf /opt/bin/crictl /opt/bin/docker /opt/bin/dasel /opt/bin/yq
ln -s /opt/crio/${BUILD_VERSION}/bin/crictl /opt/bin/crictl
ln -s /opt/crio/${BUILD_VERSION}/bin/docker /opt/bin/docker
ln -s /opt/crio/${BUILD_VERSION}/bin/dasel /opt/bin/dasel
ln -s /opt/crio/${BUILD_VERSION}/bin/yq /opt/bin/yq

rm -rf /usr/local/bin/crictl /usr/local/bin/docker /usr/local/bin/dasel /usr/local/bin/yq
ln -s /opt/crio/${BUILD_VERSION}/bin/crictl /usr/local/bin/crictl
ln -s /opt/crio/${BUILD_VERSION}/bin/docker /usr/local/bin/docker
ln -s /opt/crio/${BUILD_VERSION}/bin/dasel /usr/local/bin/dasel
ln -s /opt/crio/${BUILD_VERSION}/bin/yq /usr/local/bin/yq

# 安装cni
rm -rf /opt/cni/bin
ln -s /opt/crio/${BUILD_VERSION}/cni-plugins /opt/cni/bin

# 安装iptables
if ! [ -x "$(command -v iptables)" ]; then
  cp -r /opt/crio/${BUILD_VERSION}/iptables/usr/* /usr/local/
fi

cp /opt/crio/${BUILD_VERSION}/service/crio.service /etc/systemd/system/crio.service
cp /opt/crio/${BUILD_VERSION}/service/docker.socket /etc/systemd/system/docker.socket
cp /opt/crio/${BUILD_VERSION}/service/docker.service /etc/systemd/system/docker.service
systemctl daemon-reload

# crio , 初始化配置
if ! [ -e /etc/crio/10-crio.conf ]; then
  mkdir -p /etc/crio/
  cp /opt/crio/${BUILD_VERSION}/etc/crio/10-crio.conf /etc/crio/10-crio.conf
  cp /opt/crio/${BUILD_VERSION}/etc/crio/policy.json /etc/crio/policy.json
  mkdir -p /usr/local/share/oci-umount/oci-umount.d
  cp /opt/crio/${BUILD_VERSION}/etc/crio/crio-umount.conf /usr/local/share/oci-umount/oci-umount.d/crio-umount.conf
  cp /opt/crio/${BUILD_VERSION}/etc/crio/crictl.yaml /etc/crictl.yaml
  mkdir -p /etc/containers/registries.conf.d
  cp /opt/crio/${BUILD_VERSION}/etc/crio/registries.conf /etc/containers/registries.conf.d/registries.conf
fi

# docker , 重启docker时保持容器继续运行
if ! [ -e /etc/docker/daemon.json ]; then
  mkdir -p /etc/docker/
  cp /opt/crio/${BUILD_VERSION}/etc/docker/daemon.json /etc/docker/daemon.json
fi

# cni ， 初始化配置
if ! [ -e /etc/cni/net.d/10-crio-bridge.conflist.disabled ]; then
  mkdir -p /etc/cni/net.d
  cp /opt/crio/${BUILD_VERSION}/etc/crio/10-crio-bridge.conflist.disabled /etc/cni/net.d/10-crio-bridge.conflist.disabled
fi

if ! [ -e /etc/systemd/system/multi-user.target.wants/crio.service ]; then
  systemctl enable crio.service
fi
systemctl restart crio.service
if ! [ -e /etc/systemd/system/sockets.target.wants/docker.socket ]; then
  systemctl enable docker.socket
  systemctl restart docker.socket
fi
if ! [ -e /etc/systemd/system/multi-user.target.wants/docker.service ]; then
  systemctl enable docker.service
fi
systemctl restart docker.service
systemctl daemon-reload
