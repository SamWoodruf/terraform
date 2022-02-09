#!/bin/sh

terraform plan \
-var "databricks_account_username=swoodruff07.sw@gmail.com" \
-var "databricks_account_password=Zzoeforlife1234!" \
-var "databricks_account_id=afff152a-8214-4b02-bfa0-2e743a0c5f91" \
-var "databricks_cluster_policy_group=$POLICY_GROUP" \
-var "aws_access_key=$AWS_ACCESS_KEY_ID" \
-var "aws_secret_key=$AWS_SECRET_ACCESS_KEY" \
-var "aws_token"=$AWS_SESSION_TOKEN \
-var="region=$AWS_DEFAULT_REGION" \
