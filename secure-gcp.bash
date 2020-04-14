#!/usr/bin/env bash

PROJECT_ID=$(gcloud config list --format="value(core.project)")

echo "Authentication : GCP-managed keys"
echo
echo "No user managed service account with user managed keys unmanaged"
echo

SERVICE_ACCTS=$(gcloud iam service-accounts list --format="value(email)" | grep iam.gserviceaccount.com | tr -s "\n" " ")

for i in $SERVICE_ACCTS
do
  echo "IAM service account: $i"
  gcloud iam service-accounts keys list --iam-account=$i --managed-by=user

  KEY=""
  KEY=$(gcloud iam service-accounts keys list --iam-account=$i --managed-by=user --format="value(name)")
  if [[ "$KEY" != "" ]]
  then
    gcloud iam service-accounts keys delete --iam-account=$i $KEY
  fi
  echo
done


echo "Authorization : No Service Account User role"
echo
echo "Ensure that IAM users are not assigned Service Account User role at project level"
echo

gcloud projects get-iam-policy $PROJECT_ID --format=json | grep "roles/iam.serviceAccountUser"

echo "Networking : SSH access"
echo
echo "Ensure that SSH access is restricted from the internet"
echo

gcloud compute firewall-rules list --format=table'(name,direction,sourceRanges,allowed.ports,disabled)' \
  --filter="disabled=false AND direction=INGRESS" | grep 22 | grep 0.0.0.0/0

# gcloud compute firewall-rules update <rule name> --disabled


echo "Networking : RDP access"
echo
echo "Ensure that RDP access is restricted from the internet"
echo

gcloud compute firewall-rules list --format=table'(name,direction,sourceRanges,allowed.ports,disabled)' \
  --filter="disabled=false AND direction=INGRESS" | grep 3389 | grep 0.0.0.0/0

# gcloud compute firewall-rules update <rule name> --disabled


echo "Networking : Private Google Access"
echo
echo "Ensure Private Google Access is enabled for all subnetwork in VPC Network"
echo

gcloud compute networks subnets list --filter="privateIpGoogleAccess=false"

gcloud compute networks subnets list --filter="privateIpGoogleAccess=false" --format="value(region)" | while read i
do
    echo "gcloud compute networks subnets update default --region=$i --enable-private-ip-google-access"
    eval "gcloud compute networks subnets update default --region=$i --enable-private-ip-google-access"
done

gcloud compute networks subnets list --filter="privateIpGoogleAccess=false"


echo "Storage : No publicly accessible storage"
echo
echo "Ensure Private Google Access is enabled for all subnetwork in VPC Network"
echo


gsutil ls | while read i
do
  echo "$i: "
  gsutil iam get $i | grep role | egrep '(allUsers|allAuthenticatedUsers)'
  echo
done
