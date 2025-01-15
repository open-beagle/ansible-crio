#!/bin/sh

set -ex

# HTTPS服务器
HTTP_SERVER="${HTTP_SERVER:-https://cache.ali.wodcloud.com}"
# 平台架构
CRIO_ARCH="${CRIO_ARCH:-amd64}"
# DOCKER版本
CRIO_VERSION="${CRIO_VERSION:-v1.30.8}"

LOCAL_ARCH=$(uname -m)
if [ "$LOCAL_ARCH" = "x86_64" ]; then
  CRIO_ARCH="amd64"
elif [ "$(echo $LOCAL_ARCH | head -c 5)" = "armv8" ]; then
  CRIO_ARCH="arm64"
elif [ "$LOCAL_ARCH" = "aarch64" ]; then
  CRIO_ARCH="arm64"
elif [ "$LOCAL_ARCH" = "loongarch64" ]; then
  CRIO_ARCH="loong64"
else
  CRIO_ARCH="unsupported"
fi
if [ "$LOCAL_ARCH" = "unsupported" ]; then
  echo "This system's architecture ${LOCAL_ARCH} isn't supported"
  exit 0
fi

if ! [ -e /opt/crio/${CRIO_VERSION}/scripts/install.sh ]; then
  rm -rf /$CRIO_VERSION
  mkdir -p /opt/crio/$CRIO_VERSION
  # 下载文件
  # ansible-crio-${CRIO_VERSION}-$CRIO_ARCH.tgz 68MB
  if ! [ -e /opt/crio/ansible-crio-${CRIO_VERSION}-$CRIO_ARCH.tgz ]; then
    # 下载文件
    # ansible-crio-${CRIO_VERSION}-$CRIO_ARCH.tgz 68MB
    curl -fL $HTTP_SERVER/kubernetes/ansible/ansible-crio-${CRIO_VERSION}-$CRIO_ARCH.tgz >/opt/crio/ansible-crio-${CRIO_VERSION}-$CRIO_ARCH.tgz
  fi
  tar -xzvf /opt/crio/ansible-crio-${CRIO_VERSION}-$CRIO_ARCH.tgz -C /opt/crio/$CRIO_VERSION
  rm -rf /opt/crio/ansible-crio-${CRIO_VERSION}-$CRIO_ARCH.tgz
fi

. /opt/crio/${CRIO_VERSION}/scripts/install.sh
