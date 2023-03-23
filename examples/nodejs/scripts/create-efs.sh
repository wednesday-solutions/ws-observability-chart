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
    echo "applicationName cannot be empty"
    exit
fi

if [ -z "$regionCode" ]
then
    echo "regionCode cannot be empty"
    exit
fi

if [ -z "$securityGroupId" ]
then
    echo "securityGroupId cannot be empty"
    exit
fi


vpc_id=$(aws eks describe-cluster \
    --name $clusterName \
    --query "cluster.resourcesVpcConfig.vpcId" \
    --output text \
    --region $regionCode \
    --no-cli-pager)

cidr_range=$(aws ec2 describe-vpcs \
    --vpc-ids $vpc_id \
    --query "Vpcs[].CidrBlock" \
    --output text \
    --region $regionCode \
    --no-cli-pager)

aws ec2 authorize-security-group-ingress \
    --group-id $securityGroupId \
    --protocol tcp \
    --port 2049 \
    --region $regionCode \
    --cidr $cidr_range \
    --no-cli-pager

file_system_id=$(aws efs create-file-system \
    --region $regionCode \
    --performance-mode generalPurpose \
    --query 'FileSystemId' \
    --tags Key=Name,Value="efs-elasticsearch" \
    --output text \
    --no-cli-pager)

echo "File System Id for elasticsearch : $file_system_id" 

file_system_id=$(aws efs create-file-system \
    --region $regionCode \
    --performance-mode generalPurpose \
    --query 'FileSystemId' \
    --tags Key=Name,Value="efs-prometheus-server" \
    --output text \
    --no-cli-pager)

echo "File System Id for prometheus-server : $file_system_id"    

file_system_id=$(aws efs create-file-system \
    --region $regionCode \
    --performance-mode generalPurpose \
    --query 'FileSystemId' \
    --tags Key=Name,Value="efs-grafana" \
    --output text \
    --no-cli-pager)


echo "File System Id for grafana: $file_system_id"  

aws ec2 describe-subnets \
    --filters "Name=vpc-id,Values=$vpc_id" \
    --query 'Subnets[*].{SubnetId: SubnetId,AvailabilityZone: AvailabilityZone,CidrBlock: CidrBlock}' \
    --output table