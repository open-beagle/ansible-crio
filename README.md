# QuickStart Install CRI-O

## 在线安装 CRI-O

```bash
sudo curl -sfL https://cache.wodcloud.com/kubernetes/k8s/crio/install.sh | sh -
```

## 离线安装 CRI-O

```bash
# HTTPS服务器
HTTP_SERVER="https://cache.wodcloud.com"
# 平台架构 amd64 arm64
TARGET_ARCH="amd64"
# 台版本
TARGET_VERSION="v1.30.1"

mkdir -p /opt/crio
# 下载资源文件
curl $HTTP_SERVER/kubernetes/k8s/crio/$TARGET_ARCH/crio-$TARGET_VERSION.tgz > /opt/crio/crio-$TARGET_VERSION.tgz
# 下载安装脚本
curl $HTTP_SERVER/kubernetes/k8s/crio/install.sh > /opt/crio/install.sh

# 安装crio
bash /opt/crio/install.sh
```

## 卸载 crio

```bash
sudo curl -sfL https://cache.wodcloud.com/kubernetes/k8s/crio/uninstall.sh | sh -
```
