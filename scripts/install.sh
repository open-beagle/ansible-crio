#!/bin/sh

export PATH=/usr/sbin:$PATH

set -ex

# HTTPS服务器
HTTP_SERVER="${HTTP_SERVER:-https://cache.wodcloud.com}"
# 平台架构
TARGET_ARCH="${TARGET_ARCH:-amd64}"
# 平台版本
TARGET_VERSION="${TARGET_VERSION:-v1.30.0}"

LOCAL_ARCH=$(uname -m)
if [ "$LOCAL_ARCH" = "x86_64" ]; then
  TARGET_ARCH="amd64"
elif [ "$(echo $LOCAL_ARCH | head -c 5)" = "armv8" ]; then
  TARGET_ARCH="arm64"
elif [ "$LOCAL_ARCH" = "aarch64" ]; then
  TARGET_ARCH="arm64"
elif [ "$LOCAL_ARCH" = "loongarch64" ]; then
  TARGET_ARCH="loong64"
elif [ "$(echo $LOCAL_ARCH | head -c 5)" = "ppc64" ]; then
  TARGET_ARCH="ppc64le"
elif [ "$(echo $LOCAL_ARCH | head -c 6)" = "mips64" ]; then
  TARGET_ARCH="mips64le"
else
  TARGET_ARCH="unsupported"
fi
if [ "$LOCAL_ARCH" = "unsupported" ]; then
  echo "This system's architecture ${LOCAL_ARCH} isn't supported"
  exit 0
fi

mkdir -p /opt/bin /opt/crio

ENV_OPT="/opt/bin:$PATH"
if ! (grep -q /opt/bin /etc/environment) ; then
  cat > /etc/environment <<-EOF
PATH="${ENV_OPT}"
EOF
fi

if [ -e /opt/crio/crio-$TARGET_VERSION.md ]; then
  exit 0 
fi

if ! [ -e /opt/crio/crio-$TARGET_VERSION.tgz ]; then
  mkdir -p /opt/crio
  # 下载文件
  # crio-$TARGET_VERSION.tgz 68MB
  curl $HTTP_SERVER/kubernetes/k8s/crio/$TARGET_ARCH/crio-$TARGET_VERSION.tgz > /opt/crio/crio-$TARGET_VERSION.tgz
fi

mkdir -p /opt/crio/$TARGET_VERSION
tar -xzvf /opt/crio/crio-$TARGET_VERSION.tgz -C /opt/crio/$TARGET_VERSION
rm -rf /opt/crio/crio-$TARGET_VERSION.tgz
touch /opt/crio/crio-$TARGET_VERSION.md

rm -rf /opt/bin/crun
cp /opt/crio/$TARGET_VERSION/crun /opt/bin/crun

rm -rf /opt/bin/crictl
cp /opt/crio/$TARGET_VERSION/crictl /opt/bin/crictl

rm -rf /opt/bin/conmon /opt/bin/crio /opt/bin/pinns
cp /opt/crio/$TARGET_VERSION/crio/usr/bin/conmon /opt/bin/conmon
cp /opt/crio/$TARGET_VERSION/crio/usr/bin/crio /opt/bin/crio
cp /opt/crio/$TARGET_VERSION/crio/usr/bin/pinns /opt/bin/pinns

rm -rf /opt/cni/bin
mkdir -p /opt/cni/bin
cp /opt/crio/$TARGET_VERSION/cni-plugins/* /opt/cni/bin

if ! [ -e /opt/cni/bin/portmap ]; then
  mkdir -p /opt/cni/bin
  cp -r /opt/crio/$TARGET_VERSION/cni-plugins/* /opt/cni/bin/
fi 

if ! [ -x "$(command -v iptables)" ]; then
  cp -r /opt/crio/$TARGET_VERSION/iptables/usr/* /usr/local/
fi 

if ! [ -e /etc/crio/crio.conf ]; then
  cp -r /opt/crio/$TARGET_VERSION/crio/etc/* /etc
  sed -i "s/\/usr\/lib\/cri-o-runc\/sbin\/runc/\/opt\/bin\/crun/g" /etc/crio/crio.conf.d/01-crio-runc.conf
fi 

if ! [ -e /usr/share/bash-completion/completions/crio ]; then
  cp -r /opt/crio/$TARGET_VERSION/crio/usr/share/* /usr/share
fi 

if ! [ -e /usr/lib/systemd/system/crio.service ]; then
  cp -r /opt/crio/$TARGET_VERSION/crio/usr/lib/systemd/system/* /etc/systemd/system/
  sed -i "s/\/usr\/bin\/crio/\/opt\/bin\/crio/g" /etc/systemd/system/crio.service
  sed -i "s/kubelet.service/k8s-kubelet.service/g" /etc/systemd/system/crio.service
fi

systemctl daemon-reload

if systemctl is-active --quiet crio.service; then
    echo "crio.service is running."
else
    systemctl enable crio.service
    systemctl start crio.service
fi