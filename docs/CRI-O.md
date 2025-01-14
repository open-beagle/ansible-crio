# CRI-O

```bash
# https://storage.googleapis.com/cri-o/artifacts/cri-o.amd64.v1.30.8.tar.gz
# https://storage.googleapis.com/cri-o/artifacts/cri-o.arm64.v1.30.8.tar.gz\
export CRIO_VERSION=v1.30.8 && \
mkdir -p ./.tmp && \
curl \
  -x $SOCKS5_PROXY_LOCAL \
  -fL https://storage.googleapis.com/cri-o/artifacts/cri-o.amd64.$CRIO_VERSION.tar.gz \
  -o ./.tmp/cri-o.amd64.$CRIO_VERSION.tar.gz && \
curl \
  -x $SOCKS5_PROXY_LOCAL \
  -fL https://storage.googleapis.com/cri-o/artifacts/cri-o.arm64.$CRIO_VERSION.tar.gz \
  -o ./.tmp/cri-o.arm64.$CRIO_VERSION.tar.gz && \
mc cp ./.tmp/*.tar.gz aliyun/vscode/crio/
```

## unzip

```bash\
mkdir -p .tmp/cri-o-v1.30.8-amd64 && \
mkdir -p .tmp/cri-o-v1.30.8-arm64 && \  
tar -xzvf .tmp/cri-o.amd64.v1.30.8.tar.gz -C .tmp/cri-o-v1.30.8-amd64/ && \
tar -xzvf .tmp/cri-o.arm64.v1.30.8.tar.gz -C .tmp/cri-o-v1.30.8-arm64/
```
