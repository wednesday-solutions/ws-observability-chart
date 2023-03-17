FROM ubuntu:18.04 AS build
RUN apt-get update \
    && apt-get install -y curl wget gettext-base \
    && wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq \
    && chmod +x /usr/bin/yq

FROM ubuntu:18.04
RUN apt-get update && apt-get install -y bash curl
COPY --from=build /usr/bin/yq /usr/bin/yq
COPY ./init.sh /
COPY ./templates/jaeger/jaeger-instance.yaml /jaeger/jaeger.yaml
COPY ./templates/otel/otel-collector-instance.yaml /otel/otel-collector-instance.yaml
ENTRYPOINT ["/init.sh"]
