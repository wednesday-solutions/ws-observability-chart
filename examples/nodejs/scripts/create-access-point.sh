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


echo "creating access point for elasticsearch"
aws efs create-access-point --file-system-id $elasticseachFId --root-directory Path=/elasticsearch-data \
 --tags Key=Name,Value=elasticsearch-access-point

echo "creating access point for prometheus-server"
aws efs create-access-point --file-system-id $prometheusServerFId --root-directory Path=/data \
 --tags Key=Name,Value=prometheus-server-access-point

echo "creating access point for prometheus-alertmanager"
aws efs create-access-point --file-system-id $prometheusAlertManagerFId --root-directory Path=/ \
 --tags Key=Name,Value=prometheus-alertmanager-server-access-point

echo "creating access point for grafana"
aws efs create-access-point --file-system-id $grafanaFId --root-directory Path=/ \
 --tags Key=Name,Value=grafana-access-point