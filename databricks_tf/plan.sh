#!/bin/sh

terraform plan \
-var "databricks_account_username=XXXXXX" \
-var "databricks_account_password=XXXXXX" \
-var "databricks_account_id=XXXXXX" \
-var "databricks_cluster_policy_group=$POLICY_GROUP" \
-var "aws_access_key=$AWS_ACCESS_KEY_ID" \
-var "aws_secret_key=$AWS_SECRET_ACCESS_KEY" \
-var "aws_token"=$AWS_SESSION_TOKEN \
-var="region=$AWS_DEFAULT_REGION" \
