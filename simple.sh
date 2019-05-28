#! /bin/bash
bash ./testing/install-infra.sh

git clone -b release/6.5.1 https://github.com/Moshezauros/forgeops.git

# edit variables in gke-env.cfg
# project and service account
PROJECT="$(gcloud config get-value project)"
SA="$(gcloud config get-value account)"

sed -i "s/{PROJECT_ID_TO_REPLACE}/$PROJECT/g" ./forgeops/etc/gke-env.cfg
sed -i "s/{SERVICE_ACCOUNT_TO_REPLACE}/$SA/g" ./forgeops/etc/gke-env.cfg

# TO-DO: remove
echo $(gcloud config list)
echo $(kubectl version)

# long shot from the web
sudo cp /etc/kubernetes/admin.conf $HOME/
sudo chown $(id -u):$(id -g) $HOME/admin.conf
export KUBECONFIG=$HOME/admin.conf

echo $(kubectl version)
# ?ingress ip

# run bg-bke-up.sh
# chmod -R 777 ./forgeops
# cd ./forgeops/bin
# bash ./bg-gke-up.sh
# bash ./bg-deploy-prometheus.sh