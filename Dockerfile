FROM alpine:3.11.2 as terraform

ENV TERRAFORM_VERSION=0.12.18
ENV TERRAFORM_AZURERM_PROVIDER_VERSION=1.42.0

RUN mkdir /usr/providers

RUN apk update && \
    # apk add curl ca-certificates bash openssl git unzip wget && \
    rm -rf /var/cache/apk/* && \
    cd /tmp && \
    wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/bin && \
    wget -O terraform-provider.zip https://releases.hashicorp.com/terraform-provider-azurerm/${TERRAFORM_AZURERM_PROVIDER_VERSION}/terraform-provider-azurerm_${TERRAFORM_AZURERM_PROVIDER_VERSION}_linux_amd64.zip && \
    unzip -d /usr/providers terraform-provider.zip && \
    cp /usr/providers/terraform-provider-azurerm_v${TERRAFORM_AZURERM_PROVIDER_VERSION}_x4 /usr/bin

FROM mcr.microsoft.com/azure-cli

ARG JENKINS_USER="10011"
ARG JENKINS_USERNAME="cicduser"

RUN addgroup -g $JENKINS_USER $JENKINS_USERNAME && \
    adduser -D -u $JENKINS_USER -G $JENKINS_USERNAME -g '' $JENKINS_USERNAME && \
    echo "$JENKINS_USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN apk update && apk add git 

COPY cacert.pem /usr/local/share/ca-certificates/cacert.pem

RUN update-ca-certificates

COPY --from=terraform /usr/providers/terraform-provider-azurerm_v1.42.0_x4 /usr/local/bin
COPY --from=terraform /usr/bin/terraform /usr/local/bin

ENV http_proxy=http://nonprod.inetgw.aa.com:9093/ \
    https_proxy=http://nonprod.inetgw.aa.com:9093/ \
    no_proxy="artifacts.aa.com, nexusread.aa.com"

USER root
