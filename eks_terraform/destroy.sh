terraform destroy \
-var="region=$AWS_DEFAULT_REGION" \
-var="aws_access_key=$AWS_ACCESS_KEY_ID" \
-var="aws_secret_key=$AWS_SECRET_ACCESS_KEY" \
-var="aws_token"=$AWS_SESSION_TOKEN \
-var="cluster_name=$CONFIG_EKS_CLUSTER_NAME"
