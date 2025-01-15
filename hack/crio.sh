#!/bin/sh

set -ex

# HTTPS服务器
HTTP_SERVER="${HTTP_SERVER:-https://cache.ali.wodcloud.com}"
# 平台架构
BUILD_ARCH="${BUILD_ARCH:-amd64}"
# DOCKER版本
BUILD_VERSION="${BUILD_VERSION:-v1.30.8}"

mkdir -p .tmp/cri-o-$BUILD_VERSION-$BUILD_ARCH
curl \
  -o .tmp/cri-o.$BUILD_ARCH.$BUILD_VERSION.tar.gz \
  -fL https://cache.ali.wodcloud.com/vscode/crio/cri-o.$BUILD_ARCH.$BUILD_VERSION.tar.gz
tar -xzvf .tmp/cri-o.$BUILD_ARCH.$BUILD_VERSION.tar.gz -C .tmp/cri-o-$BUILD_VERSION-$BUILD_ARCH

mkdir -p dist/linux-$BUILD_ARCH/bin/
mkdir -p dist/linux-$BUILD_ARCH/cni-plugins/
mkdir -p dist/linux-$BUILD_ARCH/etc/crio/
cp -r .tmp/cri-o-$BUILD_VERSION-$BUILD_ARCH/cri-o/bin/* dist/linux-$BUILD_ARCH/bin/
cp -r .tmp/cri-o-$BUILD_VERSION-$BUILD_ARCH/cri-o/cni-plugins/* dist/linux-$BUILD_ARCH/cni-plugins/
cp -r .tmp/cri-o-$BUILD_VERSION-$BUILD_ARCH/cri-o/contrib/* dist/linux-$BUILD_ARCH/etc/crio/
cp -r .tmp/cri-o-$BUILD_VERSION-$BUILD_ARCH/cri-o/etc/* dist/linux-$BUILD_ARCH/etc/crio/
