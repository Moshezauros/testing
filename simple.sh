#! /bin/bash
bash ./testing/install-infra.sh

git clone -b release/6.5.1 https://github.com/ForgeRock/forgeops.git 
# git clone -b release/6.5.1 https://github.com/Moshezauros/forgeops.git

# copy relevant files from here to forgeops folder
cp -p ./testing/bg-files/bg-deploy-prometheus.sh ./testing/bg-files/bg-gke-create-cluster.sh ./testing/bg-files/bg-gke-up.sh /forgeops/bin/
cp -p ./testing/bg-files/gke-env.cfg /forgeops/etc/
cp -p ./testing/bg-files/bg-kube-prometheus.yaml /forgeops/etc/prometheus-values/

# edit variables in gke-env.cfg
# project and service account
PROJECT="$(gcloud config get-value project)"
SA="$(gcloud config get-value account)"

sed -i "s/{PROJECT_ID_TO_REPLACE}/$PROJECT/g" ./forgeops/etc/gke-env.cfg
sed -i "s/{SERVICE_ACCOUNT_TO_REPLACE}/$SA/g" ./forgeops/etc/gke-env.cfg

# this is done to use the service account credentials (in this case, the key in creds.json)
# see: https://github.com/kubernetes/kubernetes/issues/30617
gcloud config set container/use_client_certificate False

# create .kube/config
mkdir /.kube
touch /.kube/config
chmod -R 777 /.kube
export KUBECONFIG=/.kube/config

# consider moving this to terraform script
# ingress ip - create static ip and save to env variables
# gcloud compute addresses create ip-1 --global
gcloud compute addresses create ip-1 --region us-central1
ip=$(gcloud compute addresses list | grep 'ip-1' -m1 | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}')
echo $ip
sed -i "s/{IP_TO_REPLACE}/$ip/g" ./forgeops/etc/gke-env.cfg

# run bg-bke-up.sh
chmod -R 777 ./forgeops
cd ./forgeops/bin
bash ./bg-gke-up.sh

# uncomment to enable monitoring, or update bg-gke-up.sh 
# bash ./bg-deploy-prometheus.sh

# this is the student part
kubectl create namespace not-default
kubectl config set-context --current --namespace=not-default
cd /forgeops/helm

# trying to set HELM_HOME to an absolute path (see https://github.com/helm/helm/issues/4659)
echo "TESTING HERE ------"
export HELM_HOME=/.helm/
helm init --client-only --upgrade
echo $HELM_HOME
echo "TESTING HERE ------"

helm dependency update cmp-platform
echo "MARKER 2"
helm install cmp-platform
echo "MARKER 3"

# delete this machine
# gcloud compute instances delete $0