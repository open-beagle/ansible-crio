# QuickStart Install CRI-O

## 在线安装 CRI-O

```bash
# 安装最新版本
export CRIO_VERSION=v1.30.8 && \
mkdir -p /opt/crio && \
curl -sL https://cache.ali.wodcloud.com/kubernetes/ansible/ansible-crio.sh > /opt/crio/ansible-crio.sh && \
bash /opt/crio/ansible-crio.sh
```

## 离线安装 CRI-O

```bash
## amd64
mkdir -p /opt/crio/v1.30.8 && \
curl https://cache.ali.wodcloud.com/kubernetes/ansible/ansible-crio-v1.30.8-amd64.tgz > /opt/crio/ansible-crio-v1.30.8-amd64.tgz && \
tar -xzvf /opt/crio/ansible-crio-v1.30.8-amd64.tgz -C /opt/crio/v1.30.8 && \
bash /opt/crio/v1.30.8/scripts/install.sh

## arm64
mkdir -p /opt/crio/v1.30.8 && \
curl https://cache.ali.wodcloud.com/kubernetes/ansible/ansible-crio-v1.30.8-arm64.tgz > /opt/crio/ansible-crio-v1.30.8-arm64.tgz && \
tar -xzvf /opt/crio/ansible-crio-v1.30.8-arm64.tgz -C /opt/crio/v1.30.8 && \
bash /opt/crio/v1.30.8/scripts/install.sh
```

## 卸载 CRI-O

```bash
curl -sfL https://cache.ali.wodcloud.com/kubernetes/ansible/ansible-crio-uninstall.sh | sh -
```
