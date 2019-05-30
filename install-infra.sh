#! /bin/bash
# kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
mv ./kubectl /usr/local/bin/kubectl

# create kubeconfig dir and file
mkdir $HOME/.kube
chmod 777 -R $HOME/.kube
echo "" > $HOME/.kube/config
export KUBECONFIG=$HOME/.kube/config
echo $($HOME)
echo $($KUBECONFIG)

# helm version 2.12.3
wget  -P ./ "https://storage.googleapis.com/kubernetes-helm/helm-v2.12.3-linux-amd64.tar.gz"
tar -zxvf helm-v2.12.3-linux-amd64.tar.gz
mv ./linux-amd64/helm /bin/helm

# kubectx \ kubens
git clone https://github.com/ahmetb/kubectx /opt/kubectx
ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
ln -s /opt/kubectx/kubens /usr/local/bin/kubens