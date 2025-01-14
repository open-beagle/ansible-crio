#!/bin/sh

set -ex

# HTTPS服务器
HTTP_SERVER="${HTTP_SERVER:-https://cache.ali.wodcloud.com}"
# 平台架构
BUILD_ARCH="${BUILD_ARCH:-amd64}"
# DOCKER版本
BUILD_VERSION="${BUILD_VERSION:-v1.30.8}"

mkdir -p .tmp/
curl \
  -o .tmp/cri-o.$BUILD_ARCH.$BUILD_VERSION.tar.gz \
  -fL https://cache.ali.wodcloud.com/vscode/crio/cri-o.$BUILD_ARCH.$BUILD_VERSION.tar.gz
tar -xzvf .tmp/cri-o.$BUILD_ARCH.$BUILD_VERSION.tar.gz -C .tmp/cri-o-$BUILD_VERSION-$BUILD_ARCH

mkdir -p dist/linux-$BUILD_ARCH/bin/
mkdir -p dist/linux-$BUILD_ARCH/etc/crio/
cp -r .tmp/cri-o-$BUILD_VERSION-$BUILD_ARCH/crio/bin/* dist/linux-$BUILD_ARCH/bin/
cp -r .tmp/cri-o-$BUILD_VERSION-$BUILD_ARCH/crio/cni-plugins/* dist/linux-$BUILD_ARCH/bin/
cp -r .tmp/cri-o-$BUILD_VERSION-$BUILD_ARCH/crio/contrib/* dist/linux-$BUILD_ARCH/etc/crio/
cp -r .tmp/cri-o-$BUILD_VERSION-$BUILD_ARCH/crio/etc/* dist/linux-$BUILD_ARCH/etc/crio/
