#!/bin/sh

databricks_host=$1
token=$2
job_id=$3

if [ -z $databricks_host ] ; then
  echo "Databricks host needed as first argument" && exit 1;
fi
if [ -z $token ] ; then
  echo "API token needed to call databricks as second argument" && exit 2;
fi
if [ -z $job_id ] ; then
  echo "Job id it needed to create a run" && exit 3;
fi

echo "TOKEN: ${token}"
curl -L -X POST ${databricks_host}/api/2.1/jobs/run-now \
-H "Authorization: Bearer ${token}" \
-H "Content-Type: application/json" \
 --data-raw '{
    "job_id": "'$job_id'"
}'
