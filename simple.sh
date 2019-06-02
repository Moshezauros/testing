#! /bin/bash
bash ./testing/install-infra.sh

#git clone -b release/6.5.1 https://github.com/ForgeRock/forgeops.git 
git clone -b release/6.5.1 https://github.com/Moshezauros/forgeops.git

# edit variables in gke-env.cfg
# project and service account
PROJECT="$(gcloud config get-value project)"
SA="$(gcloud config get-value account)"

sed -i "s/{PROJECT_ID_TO_REPLACE}/$PROJECT/g" ./forgeops/etc/gke-env.cfg
sed -i "s/{SERVICE_ACCOUNT_TO_REPLACE}/$SA/g" ./forgeops/etc/gke-env.cfg

# TO-DO: remove
# see: https://github.com/kubernetes/kubernetes/issues/30617
gcloud config set container/use_client_certificate False

# create .kube/config
mkdir /.kube
touch /.kube/config
chmod -R 777 /.kube
export KUBECONFIG=/.kube/config

# ingress ip - create static ip and save to env variables
gcloud compute addresses create ip-1 --global
ip=$(gcloud compute addresses list | grep 'ip-1' -m1 | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}')
echo $ip
sed -i "s/{IP_TO_REPLACE}/$ip/g" ./forgeops/etc/gke-env.cfg

# run bg-bke-up.sh
chmod -R 777 ./forgeops
cd ./forgeops/bin
bash ./bg-gke-up.sh

# uncomment to enable monitoring
# bash ./bg-deploy-prometheus.sh

# this is the student part
helm init --client-only --upgrade
kubectl create namespace not-default
kubens not-default
cd ./../helm
helm dependency update cmp-platform
helm install cmp-platform

# delete this machine
