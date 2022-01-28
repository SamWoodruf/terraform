#!/bin/sh

databricks_host=$1
token=$2

if [ -z $databricks_host ] ; then
  echo "Databricks host needed as first argument" && exit 1;
fi
if [ -z $token ] ; then
  echo "API token needed to call databricks as second argument" && exit 2;
fi

curl -X GET --header "Authorization: Bearer $token" \
${databricks_host}/api/2.1/jobs/list
