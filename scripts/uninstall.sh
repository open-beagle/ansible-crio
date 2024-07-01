#!/bin/sh

set -ex

systemctl stop crio.service

systemctl disable crio.service

rm -rf /etc/systemd/system/crio.service

rm -rf /opt/bin/crun

rm -rf /opt/bin/crictl

rm -rf /opt/bin/conmon /opt/bin/crio /opt/bin/pinns

rm -rf /opt/cni/bin
