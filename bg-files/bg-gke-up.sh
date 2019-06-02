#!/usr/bin/env bash
# Sample wrapper script to initialize GKE. This creates the cluster and configures Helm, the nginx ingress,
# and creates git credential secrets. Edit this for your requirements.


set -o errexit
set -o pipefail
set -o nounset

ask() {

	read -p "Should i continue (y/n)?" choice
	case "$choice" in 
   		y|Y|yes|YES ) echo "yes";;
   		n|N|no|NO ) echo "no"; exit 1;;
   		* ) echo "Invalid input, Bye!"; exit 1;;
	esac
}

echo -e "WARNING: This script requires a properly provisioned GCP Project with appropriate accounts,\n\t roles, privileges, keyrings, keys etc. It also assumes a fully functional gcloud CLI.\n\t These pre-requisites are outlined in the DevOps Documentation. Please ensure you have\n\t completed all before proceeding."


echo ""
echo "=> Have you copied the template file etc/gke-env.template to etc/gke-env.cfg and edited to cater to your enviroment?"
ask

authn=$(gcloud auth list --filter=status:ACTIVE --format="value(account)")
echo ""
echo "You are authenticated and logged into GCP as \"${authn}\". If this is not correct then exit this script and run \"gcloud auth login\" to login into the correct account first."
ask

#source "$(dirname $0)/../etc/gke-env.cfg"
source "${BASH_SOURCE%/*}/../etc/gke-env.cfg"

# Set the GKE Project ID to the one parsed from the cfg file
gcloud config set project ${GKE_PROJECT_ID}

# First ensure that additional required API are enabled
gcloud services enable \
  container.googleapis.com \
  cloudkms.googleapis.com \
  file.googleapis.com

if [ $? -ne 0 ]; then
    echo "Some of the API's could not be enabled.  Please fix manually first."
    exit 1 
fi

# Now create the cluster
# BG changed the script below to not use SSD.
./bg-gke-create-cluster.sh

# If an error is returned by the above script then exit
if [ $? -ne 0 ]; then
    exit 1
fi

# Create monitoring namespace
kubectl create namespace ${GKE_MONITORING_NS}

# Create the namespace parsed from cfg file and set the context
kubectl create namespace ${GKE_CLUSTER_NS}
kubectl config set-context $(kubectl config current-context) --namespace=${GKE_CLUSTER_NS}

# Create storage class
# BG comment out if not using fast storage 
#./gke-create-sc.sh

# Inatilize helm by creating a rbac role first
./helm-rbac-init.sh

# Need as sometimes tiller is not ready immediately
while :
do
    helm ls >/dev/null 2>&1
    test $? -eq 0 && break
    echo "Waiting on tiller to be ready..."
    sleep 5s
done


# Create the ingress controller
# BG make sure you have reserved a static IP and edited the gke-env.cfg file.
./gke-create-ingress-cntlr.sh ${GKE_INGRESS_IP}

# Deploy cert-manager
./deploy-cert-manager.sh

# Add Prometheus
# BG You can try running this manually in class for demo purposes.
# BG Don't run the default as it uses SSD, which has not been pre-allocated and will fail.
#./bg-deploy-prometheus.sh

# Filestore is needed if you enable backups.  Uncomment the next line to create one.
# BG leave this commented out as we don't use it for class and it's very expensive to run.
# ./gke-create-filestore.sh
