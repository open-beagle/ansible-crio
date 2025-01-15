#!/bin/sh

set -ex

systemctl stop crio.service

systemctl disable crio.service

# 卸载CRI-O服务
rm -rf /etc/systemd/system/crio.service

# 卸载CRI-O
rm -rf /opt/bin/crio /opt/bin/pinns

# 卸载CRI-O插件
rm -rf /usr/libexec/crio/runc /usr/libexec/crio/crun /usr/libexec/crio/conmon /usr/libexec/crio/conmonrs


# 卸载命令行工具
rm -rf /opt/bin/crictl 
rm -rf /usr/local/bin/crictl 

rm -rf /opt/crio/current