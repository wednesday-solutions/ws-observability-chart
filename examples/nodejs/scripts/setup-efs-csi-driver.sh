#!/bin/bash

for ARGUMENT in "$@"
do
   K=$(echo $ARGUMENT | cut -f1 -d=)
   KEY=${K:2}
   KEY_LENGTH=${#KEY}
   VALUE="${ARGUMENT:$KEY_LENGTH+3}"

   export "$KEY"="$VALUE"
done


if [ -z "$clusterName" ]
then
    echo "clusterName cannot be empty"
    exit
fi

if [ -z "$regionCode" ]
then
    echo "region code cannot be empty"
    exit
fi

if [ -z "$accountId" ]
then
    echo "aws accountId  cannot be empty"
    exit
fi

if [ -z "$applicationName" ]
then
    echo "application name cannot be empty"
    exit
fi

if [ -z "$env" ]
then
    echo "env cannot be empty"
    exit
fi

curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-efs-csi-driver/master/docs/iam-policy-example.json

aws iam create-policy \
    --policy-name AmazonEKS_EFS_CSI_Driver_Policy \
    --policy-document file://iam-policy-example.json \
    --region="$regionCode"

eksctl utils associate-iam-oidc-provider --region="$regionCode" --cluster="$clusterName" --approve    

eksctl create iamserviceaccount \
    --cluster "$clusterName" \
    --namespace kube-system \
    --name efs-csi-controller-sa \
    --attach-policy-arn arn:aws:iam::"$accountId":policy/AmazonEKS_EFS_CSI_Driver_Policy \
    --approve \
    --region "$regionCode"


helm repo add aws-efs-csi-driver https://kubernetes-sigs.github.io/aws-efs-csi-driver/

helm repo update

helm upgrade -i aws-efs-csi-driver aws-efs-csi-driver/aws-efs-csi-driver \
    --namespace kube-system \
    --set image.repository=602401143452.dkr.ecr."$regionCode".amazonaws.com/eks/aws-efs-csi-driver \
    --set controller.serviceAccount.create=false \
    --set controller.serviceAccount.name=efs-csi-controller-sa

echo "😃 Creating ECR repository for your application"

./scripts/create-ecr.sh --applicationName=$applicationName --env=$env --awsAccountId=$accountId --region=$regionCode

echo "⚙️ Creating helm application"

./scripts/create-helm-application.sh --applicationName=$applicationName   

echo "🚀 Building and pushing docker image to ECR cluster"

./scripts/docker-build-and-push-to-ecr.sh --region=$regionCode --applicationName=$applicationName --env=$env --awsAccountId=$accountId

securityGroupId=$(aws eks describe-cluster --name rus-basic-cluster --query "cluster.resourcesVpcConfig.securityGroupIds[]" --output text --no-cli-pager)

echo "securityGroupId $securityGroupId"

echo "🛠 Creating EFS for Elasticsearch, Prometheus and Grafana"
./scripts/create-efs.sh --clusterName=$clusterName --regionCode=$regionCode --securityGroupId=$securityGroupId    