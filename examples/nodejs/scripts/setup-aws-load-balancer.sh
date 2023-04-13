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
    echo "cluster name cannot be empty"
    exit
fi

if [ -z "$region" ]
then
    echo "region cannot be empty"
    exit
fi

if [ -z "$awsAccountId" ]
then
    echo "awsAccountId cannot be empty"
    exit
fi



curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.7/docs/install/iam_policy.json

aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json

eksctl create iamserviceaccount \
  --cluster=$clusterName \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn=arn:aws:iam::$awsAccountId:policy/AWSLoadBalancerControllerIAMPolicy \
  --region $region \
  --override-existing-serviceaccounts \
  --approve

helm repo add eks https://aws.github.io/eks-charts

helm repo update


vpcId=$(aws eks describe-cluster --name $clusterName --query 'cluster.resourcesVpcConfig.vpcId' | grep "vpc-.*")

echo $vpcId
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=$clusterName \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set vpcId="${vpcId//\"/}" \
  --set region= $region

kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller/crds?ref=master"  