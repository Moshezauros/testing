#! /bin/bash
./testing/install-infra.sh

git clone https://github.com/Moshezauros/forgeops.git

# edit variables
# project and service account
PROJECT="$(gcloud config get-value project)"
SA="$(gcloud config get-value account)"
# J=$(printf "sed -i 's/{PROJECT_ID_TO_REPLACE}/%s/g' ./forgeops/etc/gke-env.cfg" $PROJECT)
# echo "${J}"

sed -i "s/{PROJECT_ID_TO_REPLACE}/$PROJECT/g" ./forgeops/etc/gke-env.cfg
sed -i "s/{SERVICE_ACCOUNT_TO_REPLACE}/$SA/g" ./forgeops/etc/gke-env.cfg

# ?ingress ip

# run bg-bke-up.sh
cd ./forgeops/bin
bash ./bg-gke-up.sh
bash ./bg-deploy-prometheus.sh