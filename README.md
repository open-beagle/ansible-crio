# QuickStart Install CRI-O & Docker

## 在线安装 CRI-O & Docker

```bash
# 安装最新版本
export DOCKER_VERSION=v1.30.8 && \
mkdir -p /opt/docker && \
curl -sL https://cache.ali.wodcloud.com/kubernetes/ansible/ansible-crio.sh > /opt/docker/ansible-crio.sh && \
bash /opt/docker/ansible-crio.sh
```

## 离线安装 CRI-O & Docker

```bash
## amd64
mkdir -p /opt/docker/v1.30.8 && \
curl https://cache.ali.wodcloud.com/kubernetes/ansible/ansible-crio-v1.30.8-amd64.tgz > /opt/docker/ansible-crio-v1.30.8-amd64.tgz && \
tar -xzvf /opt/docker/ansible-crio-v1.30.8-amd64.tgz -C /opt/docker/v1.30.8 && \
bash /opt/docker/v1.30.8/scripts/install.sh

## arm64
mkdir -p /opt/docker/v1.30.8 && \
curl https://cache.ali.wodcloud.com/kubernetes/ansible/ansible-crio-v1.30.8-arm64.tgz > /opt/docker/ansible-crio-v1.30.8-arm64.tgz && \
tar -xzvf /opt/docker/ansible-crio-v1.30.8-arm64.tgz -C /opt/docker/v1.30.8 && \
bash /opt/docker/v1.30.8/scripts/install.sh
```

## 卸载 CRI-O & Docker

```bash
curl -sfL https://cache.ali.wodcloud.com/kubernetes/ansible/ansible-crio-uninstall.sh | sh -
```
