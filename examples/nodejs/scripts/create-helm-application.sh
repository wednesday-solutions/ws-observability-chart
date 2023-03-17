#!/bin/bash

for ARGUMENT in "$@"
do
   K=$(echo $ARGUMENT | cut -f1 -d=)
   KEY=${K:2}
   KEY_LENGTH=${#KEY}
   VALUE="${ARGUMENT:$KEY_LENGTH+3}"

   export "$KEY"="$VALUE"
done


if [ -z "$applicationName" ]
then
    echo "applicationName cannot be empty"
    exit
fi
mkdir helm
helm create helm/$applicationName
mv helm/$applicationName/values.yaml helm/$applicationName/values.dev.yaml 

sed '38 c\
              containerPort: 9000
' helm/$applicationName/templates/deployment.yaml > helm/$applicationName/templates/deployment-temp.yaml
cat helm/$applicationName/templates/deployment-temp.yaml > helm/$applicationName/templates/deployment.yaml
rm helm/$applicationName/templates/deployment-temp.yaml

yq e '.image.repository = ""'  -i helm/$applicationName/values.dev.yaml
yq e '.image.pullPolicy = "Always"'  -i helm/$applicationName/values.dev.yaml
yq e '.service.type = "NodePort", .service.targetPort = 9000'  -i helm/$applicationName/values.dev.yaml

# name change
yq e '.fullnameOverride = strenv(applicationName) + "-dev"'  -i helm/$applicationName/values.dev.yaml
yq e '.nameOverride = strenv(applicationName) + "-dev"'  -i helm/$applicationName/values.dev.yaml

# ingress

yq e '.ingress.enabled = true'  -i helm/$applicationName/values.dev.yaml

# defaultBackend
yq e '.ingress.defaultBackendServiceName = env(applicationName) + "-dev"'  -i helm/$applicationName/values.dev.yaml

#host
yq e -i 'del(.ingress.hosts[0].host)' helm/$applicationName/values.dev.yaml 
yq e '.ingress.hosts[0].paths[0].backend.service.name = env(applicationName) + "-dev"'  -i helm/$applicationName/values.dev.yaml

yq e '.ingress.hosts[0].paths[0].backend.service.port.number = 80'  -i helm/$applicationName/values.dev.yaml
yq e '.ingress.hosts[0].paths[0].path = "/"'  -i helm/$applicationName/values.dev.yaml
yq e '.ingress.hosts[0].paths[0].pathType = "ImplementationSpecific"'  -i helm/$applicationName/values.dev.yaml


# annotations
yq e '.ingress.annotations["kubernetes.io/ingress.class"] = "alb"'  -i helm/$applicationName/values.dev.yaml
yq e '.ingress.annotations["alb.ingress.kubernetes.io/scheme"] = "internet-facing"'  -i helm/$applicationName/values.dev.yaml
yq e '.ingress.annotations["alb.ingress.kubernetes.io/target-type"] = "ip"'  -i helm/$applicationName/values.dev.yaml
yq e '.podAnnotations["prometheus.io/scrape"] = "true"'  -i helm/$applicationName/values.dev.yaml
yq e '.podAnnotations["prometheus.io/port"] = "9000"'  -i helm/$applicationName/values.dev.yaml
yq e '.ingress.annotations["alb.ingress.kubernetes.io/listen-ports"] = "[{\"HTTP\":80}]"'  -i helm/$applicationName/values.dev.yaml



cp helm/$applicationName/values.dev.yaml helm/$applicationName/values.qa.yaml 
cp helm/$applicationName/values.dev.yaml helm/$applicationName/values.local.yaml 

# name change -> qa
yq e '.fullnameOverride = strenv(applicationName) + "-qa"'  -i helm/$applicationName/values.qa.yaml
yq e '.nameOverride = strenv(applicationName) + "-qa"'  -i helm/$applicationName/values.qa.yaml

# host -> qa
yq e '.ingress.hosts[0].paths[0].backend.service.name = env(applicationName) + "-qa"'  -i helm/$applicationName/values.qa.yaml

# defaultBackend -> qa
yq e '.ingress.defaultBackendServiceName = env(applicationName) + "-qa"'  -i helm/$applicationName/values.qa.yaml

# name change -> local
yq e '.fullnameOverride = strenv(applicationName) + "-local"'  -i helm/$applicationName/values.local.yaml
yq e '.nameOverride = strenv(applicationName) + "-local"'  -i helm/$applicationName/values.local.yaml

# host -> local
yq e '.ingress.hosts[0].paths[0].backend.service.name = env(applicationName) + "-local"'  -i helm/$applicationName/values.local.yaml

# defaultBackend -> local
yq e '.ingress.defaultBackendServiceName = env(applicationName) + "-local"'  -i helm/$applicationName/values.local.yaml
# defaultBackend -> local
yq e '.ingress.annotations = {}'  -i helm/$applicationName/values.local.yaml


# pullPolicy will be IfNotPresent to fulfil local builds
yq e '.image.pullPolicy = "IfNotPresent"'  -i helm/$applicationName/values.local.yaml


echo "
env:
  configmap:
    data:
      ENVIRONMENT_NAME: develop" >> helm/$applicationName/values.dev.yaml

echo "
env:
  configmap:
    data:
      ENVIRONMENT_NAME: qa" >> helm/$applicationName/values.qa.yaml


# deployment


