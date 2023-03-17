#!/bin/bash
for ARGUMENT in "$@"
do
   K=$(echo $ARGUMENT | cut -f1 -d=)
   KEY=${K:2}
   KEY_LENGTH=${#KEY}
   VALUE="${ARGUMENT:$KEY_LENGTH+3}"

   export "$KEY"="$VALUE"
done

if [ -z "$elasticseachFId" ]
then
    echo "Elastic search file id cannot be empty"
    exit
fi

if [ -z "$prometheusServerFId" ]
then
    echo "Prometheus Server file id cannot be empty"
    exit
fi

if [ -z "$prometheusAlertManagerFId" ]
then
    echo "Prometheus alert manager file id cannot be empty"
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

if [ -z "$securityGroupId" ]
then
    echo "subnet2  cannot be empty"
    exit
fi


aws efs create-mount-target \
    --file-system-id $elasticseachFId \
    --subnet-id $subnet1 \
    --security-groups $securityGroupId

aws efs create-mount-target \
    --file-system-id $elasticseachFId \
    --subnet-id $subnet2 \
    --security-groups $securityGroupId

aws efs create-mount-target \
    --file-system-id $prometheusServerFId \
    --subnet-id $subnet1 \
    --security-groups $securityGroupId

aws efs create-mount-target \
    --file-system-id $prometheusServerFId \
    --subnet-id $subnet2 \
    --security-groups $securityGroupId

aws efs create-mount-target \
    --file-system-id $prometheusAlertManagerFId \
    --subnet-id $subnet1 \
    --security-groups $securityGroupId 

aws efs create-mount-target \
    --file-system-id $prometheusAlertManagerFId \
    --subnet-id $subnet2 \
    --security-groups $securityGroupId


aws efs create-mount-target \
    --file-system-id $grafanaFId \
    --subnet-id $subnet1 \
    --security-groups $securityGroupId 

aws efs create-mount-target \
    --file-system-id $grafanaFId \
    --subnet-id $subnet2 \
    --security-groups $securityGroupId