
ARG KUBECTL_RELEASE=v1.22.0
ARG HELM_RELEASE=v3.4.2
ARG HELMSMAN_VERSION=3.4.1
ARG KUBEVAL_VERSION=v0.16.1

FROM alpine:latest AS kubectl-downloader

ARG KUBECTL_RELEASE

# Install kubectl
RUN apk add --no-cache wget curl ca-certificates && \
    wget -q https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_RELEASE}/bin/linux/amd64/kubectl && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/kubectl && \
    kubectl version; exit 0


FROM alpine:latest AS helm-downloader

ARG HELM_RELEASE

RUN apk add --no-cache wget ca-certificates && \
    wget -q https://get.helm.sh/helm-${HELM_RELEASE}-linux-amd64.tar.gz && \
    tar xvzf helm-${HELM_RELEASE}-linux-amd64.tar.gz && \
    mv linux-amd64/helm /usr/local/bin/helm

FROM alpine:latest AS helmsman-downloader

ARG HELMSMAN_VERSION

RUN apk add --no-cache wget ca-certificates && \
    wget -q https://github.com/Praqma/helmsman/releases/download/v${HELMSMAN_VERSION}/helmsman_${HELMSMAN_VERSION}_linux_amd64.tar.gz && \
    tar -zxvf helmsman_${HELMSMAN_VERSION}_linux_amd64.tar.gz && \
    chmod +x ./helmsman && \
    mv ./helmsman /usr/local/bin/

 FROM alpine:latest AS kubeval-downloader

ARG KUBEVAL_VERSION

RUN apk add --no-cache wget ca-certificates && \
	wget -q https://github.com/instrumenta/kubeval/releases/download/v0.16.1/kubeval-linux-amd64.tar.gz && \
	tar xvzf kubeval-linux-amd64.tar.gz


FROM debian:stable-slim

COPY --from=kubectl-downloader /usr/local/bin/kubectl /usr/local/bin/kubectl
COPY --from=helm-downloader /usr/local/bin/helm /usr/local/bin/helm
COPY --from=helmsman-downloader /usr/local/bin/helmsman /usr/local/bin/helmsman

RUN helm plugin install https://github.com/databus23/helm-diff --version master

