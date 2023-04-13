# Wednesday Solutions Observability Kubernetes Helm Charts

## Description

We've gone ahead and built and observability swiss-knife for your kubernetes cluster so you don't need to! 
It comes power packed with support for 
- Distributed tracing using Jaeger
- Logging with the EFK stack (ElasticSearch FluentBit and Kibana)
- Metrics and monitoring with Prometheus and Grafana

We've even got an example for nodejs and AWS to help get you started <link>

## Usage

[Helm](https://helm.sh) must be installed to use the charts.
Please refer to Helm's [documentation](https://helm.sh/docs/) to get started.

Once Helm is set up properly, add the repo as follows:

```console
helm repo add ws-observability https://wednesday-solutions.github.io/ws-observability-chart
```

You can then run `helm search repo ws-observability` to see the charts.