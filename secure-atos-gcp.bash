#!/usr/bin/env bash

echo "Authentication : Corporate login credentials"
echo
echo "No Gmail accounts should be listed."

gcloud projects list --format="value(project_id)" | while read i
do
  gcloud projects get-iam-policy $i  | grep gmail.com
done

echo
echo "Done"
echo


