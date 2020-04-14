#!/usr/bin/env bash



gcloud iam service-accounts list --format="value(email)" | while read i
do
  gcloud iam service-accounts keys list --iam-account=$i managed-by=user
done
