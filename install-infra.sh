#! /bin/bash
# kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

# helm version 2.12.3
wget  -P ./ "https://storage.googleapis.com/kubernetes-helm/helm-v2.12.3-linux-amd64.tar.gz"
tar -zxvf helm-v2.12.3-linux-amd64.tar.gz
mv ./linux-amd64/helm /bin/helm

# kubectx \ kubens
sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens