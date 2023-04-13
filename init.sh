#!/bin/bash
curl -s https://storage.googleapis.com/kubernetes-release/release/v1.13.0/bin/linux/amd64/kubectl -o /usr/bin/kubectl && chmod +x /usr/bin/kubectl;
echo "$(kubectl get pods -l name=jaeger-operator)"
ISPODREADY=$(kubectl get pods -l name=jaeger-operator --output="jsonpath={.items[*].status.containerStatuses[0].ready}");
echo "$ISPODREADY"
while [ "$ISPODREADY" != "true" ] || [ "$ISPODREADY" != true ]
do
echo "Jaeger operator is not ready";
ISPODREADY=$(kubectl get pods -l name=jaeger-operator --output="jsonpath={.items[*].status.containerStatuses[0].ready}");
echo "$ISPODREADY";
done

ISPODREADY=$(kubectl get pods -l app.kubernetes.io/name=opentelemetry-operator --output="jsonpath={.items[*].status.containerStatuses[0].ready}");
while [ "$ISPODREADY" != "true" ] || [ "$ISPODREADY" != true ]
do
echo "Open telemetry operator is not ready";
ISPODREADY=$(kubectl get pods -l app.kubernetes.io/name=opentelemetry-operator --output="jsonpath={.items[*].status.containerStatuses[0].ready}");
echo "$ISPODREADY";
done

echo "Jaeger and open telemetry operator is ready";
echo "Creating Jaeger instance"
echo "$ELASTICSEARCH_NAME"
echo "$JAEGER_ENDPOINT"
export elasticUrl="https://${ELASTICSEARCH_NAME}-es-http:9200"
export secretName="${ELASTICSEARCH_NAME}-es-http-certs-public"
echo "$elasticUrl"
echo "$secretName"
echo "$OTEL_NAME"
yq e '.spec.storage.secretName=strenv(ELASTICSEARCH_SECRET_NAME)' -i ./jaeger/jaeger.yaml
yq e '.spec.storage.options.es.server-urls=strenv(elasticUrl)' -i ./jaeger/jaeger.yaml
yq e '.spec.volumes[0].secret.secretName=strenv(secretName)' -i ./jaeger/jaeger.yaml
yq e '.metadata.name=strenv(JAEGER_NAME)' -i ./jaeger/jaeger.yaml
yq e '.metadata.name=strenv(OTEL_NAME)' -i ./otel/otel-collector-instance.yaml
cat ./otel/otel-collector-instance.yaml
kubectl apply -f "./jaeger/jaeger.yaml"
echo "Creating open telemetry collector"
sleep 120
kubectl apply -f "./otel/otel-collector-instance.yaml"
exit 0
