#!/bin/bash

terraform init && \
terraform validate && \
terraform apply -auto-approve \
-var="region=$AWS_DEFAULT_REGION" \
-var="aws_access_key=$AWS_ACCESS_KEY_ID" \
-var="aws_secret_key=$AWS_SECRET_ACCESS_KEY" \
-var="aws_token"=$AWS_SESSION_TOKEN \
-var="cluster_name=$CONFIG_EKS_CLUSTER_NAME"

export KUBECONFIG="$PWD/kubeconfig_$CONFIG_EKS_CLUSTER_NAME"

kubectl create namespace argo
kubectl apply -n argo -f manifests/argo.yaml
kubectl -n argo create rolebinding default-admin --clusterrole=admin --serviceaccount=argo:default
# kubectl -n argo patch svc argo-server -p '{"spec": {"type": "LoadBalancer"}}'
