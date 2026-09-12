#!/bin/bash
set -e

curl -sfL https://get.k3s.io | sh -

sleep 10
chmod 644 /etc/rancher/k3s/k3s.yaml

echo "k3s instalado com sucesso" > /var/log/k3s-install.log