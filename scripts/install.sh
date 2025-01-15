#!/bin/sh

export PATH=/usr/sbin:$PATH

set -ex

# CRI-O架构
CRIO_ARCH="${CRIO_ARCH:-amd64}"
# CRI-O版本
CRIO_VERSION="${CRIO_VERSION:-v1.30.8}"

LOCAL_ARCH=$(uname -m)
if [ "$LOCAL_ARCH" = "x86_64" ]; then
  CRIO_ARCH="amd64"
elif [ "$(echo $LOCAL_ARCH | head -c 5)" = "armv8" ]; then
  CRIO_ARCH="arm64"
elif [ "$LOCAL_ARCH" = "aarch64" ]; then
  CRIO_ARCH="arm64"
elif [ "$LOCAL_ARCH" = "loongarch64" ]; then
  CRIO_ARCH="unsupported"
else
  CRIO_ARCH="unsupported"
fi
if [ "$LOCAL_ARCH" = "unsupported" ]; then
  echo "This system's architecture ${LOCAL_ARCH} isn't supported"
  exit 1
fi

mkdir -p /opt/bin /opt/cni

# 安装bin/crio
if [ -L "/opt/crio/current" ] && [ "$(readlink -f "/opt/crio/current")" = "/opt/crio/${CRIO_VERSION}" ]; then
  echo "版本${CRIO_VERSION}，系统已安装，如若需要更新请先卸载。"
  exit 0
else
  rm -rf /opt/crio/current
  ln -s /opt/crio/${CRIO_VERSION} /opt/crio/current
fi

# 安装crio
rm -rf /opt/bin/crio /opt/bin/pinns
ln -s /opt/crio/${CRIO_VERSION}/bin/crio /opt/bin/crio
ln -s /opt/crio/${CRIO_VERSION}/bin/pinns /opt/bin/pinns

# 安装crio插件-runc crun conmon conmonrs
rm -rf /usr/libexec/crio/runc /usr/libexec/crio/crun /usr/libexec/crio/conmon /usr/libexec/crio/conmonrs
mkdir -p /usr/libexec/crio
ln -s /opt/crio/${CRIO_VERSION}/bin/runc /usr/libexec/crio/runc
ln -s /opt/crio/${CRIO_VERSION}/bin/crun /usr/libexec/crio/crun
ln -s /opt/crio/${CRIO_VERSION}/bin/conmon /usr/libexec/crio/conmon
ln -s /opt/crio/${CRIO_VERSION}/bin/conmonrs /usr/libexec/crio/conmonrs

# 将 crictl命令安装至全局
rm -rf /opt/bin/crictl
ln -s /opt/crio/${CRIO_VERSION}/bin/crictl /opt/bin/crictl

rm -rf /usr/local/bin/crictl
ln -s /opt/crio/${CRIO_VERSION}/bin/crictl /usr/local/bin/crictl

# 安装cni
if [ -L "/opt/cni/bin" ]; then
  echo $(readlink -f "/opt/cni/bin")
else
  rm -rf /opt/cni/bin
  ln -s /opt/crio/${CRIO_VERSION}/cni-plugins /opt/cni/bin
fi

cp /opt/crio/${CRIO_VERSION}/service/crio.service /etc/systemd/system/crio.service
systemctl daemon-reload

# crio , 初始化配置
if ! [ -e /etc/crio/10-crio.conf ]; then
  mkdir -p /etc/crio/
  cp /opt/crio/${CRIO_VERSION}/etc/crio/10-crio.conf /etc/crio/crio.conf.d/10-crio.conf
  cp /opt/crio/${CRIO_VERSION}/etc/crio/policy.json /etc/crio/policy.json
  mkdir -p /usr/local/share/oci-umount/oci-umount.d
  cp /opt/crio/${CRIO_VERSION}/etc/crio/crio-umount.conf /usr/local/share/oci-umount/oci-umount.d/crio-umount.conf
  cp /opt/crio/${CRIO_VERSION}/etc/crio/crictl.yaml /etc/crictl.yaml
  mkdir -p /etc/containers/registries.conf.d
  cp /opt/crio/${CRIO_VERSION}/etc/crio/registries.conf /etc/containers/registries.conf.d/registries.conf
  mkdir -p /etc/sysconfig/
  cp /opt/crio/${CRIO_VERSION}/etc/crio/crio /etc/sysconfig/crio
fi

# cni ， 初始化配置
if ! [ -e /etc/cni/net.d/10-crio-bridge.conflist.disabled ]; then
  mkdir -p /etc/cni/net.d
  cp /opt/crio/${CRIO_VERSION}/etc/crio/10-crio-bridge.conflist.disabled /etc/cni/net.d/10-crio-bridge.conflist.disabled
fi

if ! [ -e /etc/systemd/system/multi-user.target.wants/crio.service ]; then
  systemctl enable crio.service
fi
systemctl restart crio.service
