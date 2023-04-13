#!/bin/bash
for ARGUMENT in "$@"
do
   K=$(echo $ARGUMENT | cut -f1 -d=)
   KEY=${K:2}
   KEY_LENGTH=${#KEY}
   VALUE="${ARGUMENT:$KEY_LENGTH+3}"
   export "$KEY"="$VALUE"
done

if [ -z "$elasticsearchFId" ]
then
    echo "Elastic search file id cannot be empty"
    exit
fi

if [ -z "$prometheusServerFId" ]
then
    echo "Prometheus Server file id cannot be empty"
    exit
fi

if [ -z "$grafanaFId" ]
then
    echo "Prometheus alert manager file id cannot be empty"
    exit
fi


if [ -z "$subnet1" ]
then
    echo "subnet1  cannot be empty"
    exit
fi

if [ -z "$subnet2" ]
then
    echo "subnet2  cannot be empty"
    exit
fi

if [ -z "$regionCode" ]
then
    echo "region code  cannot be empty"
    exit
fi

if [ -z "$clusterName" ]
then
    echo "clusterName  cannot be empty"
    exit
fi

securityGroupId=$(aws eks describe-cluster --name $clusterName --query "cluster.resourcesVpcConfig.securityGroupIds[]" --output text --no-cli-pager)

echo "securityGroupId $securityGroupId"

aws efs create-mount-target \
    --file-system-id $elasticsearchFId \
    --subnet-id $subnet1 \
    --security-groups $securityGroupId \
    --region $regionCode \
    --no-cli-pager

aws efs create-mount-target \
    --file-system-id $elasticsearchFId \
    --subnet-id $subnet2 \
    --security-groups $securityGroupId \
    --region $regionCode \
    --no-cli-pager    

aws efs create-mount-target \
    --file-system-id $prometheusServerFId \
    --subnet-id $subnet1 \
    --security-groups $securityGroupId \
    --region $regionCode \
    --no-cli-pager    

aws efs create-mount-target \
    --file-system-id $prometheusServerFId \
    --subnet-id $subnet2 \
    --security-groups $securityGroupId \
    --region $regionCode \
    --no-cli-pager    

aws efs create-mount-target \
    --file-system-id $grafanaFId \
    --subnet-id $subnet1 \
    --security-groups $securityGroupId \
    --region $regionCode \
    --no-cli-pager     

aws efs create-mount-target \
    --file-system-id $grafanaFId \
    --subnet-id $subnet2 \
    --security-groups $securityGroupId \
    --region $regionCode \
    --no-cli-pager    



echo "🧰 Creating access points for ElasticSearch, Promatheus and Grafana"
./scripts/create-access-point.sh --elasticseachFId=$elasticsearchFId --prometheusServerFId=$prometheusServerFId --grafanaFId=$grafanaFId

