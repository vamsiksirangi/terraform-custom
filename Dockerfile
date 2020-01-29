FROM alpine:3.11.2

ENV TERRAFORM_VERSION=0.12.18
ENV TERRAFORM_AZURERM_PROVIDER_VERSION=1.42.0

ARG JENKINS_USER="10011"
ARG JENKINS_USERNAME="cicduser"

RUN addgroup -g $JENKINS_USER $JENKINS_USERNAME && \
    adduser -D -u $JENKINS_USER -G $JENKINS_USERNAME -g '' $JENKINS_USERNAME && \
    echo "$JENKINS_USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

#COPY cacert.pem /home/${JENKINS_USERNAME}/cacerts/cacert.pem
#
RUN mkdir /usr/providers

RUN apk update && \
    apk add curl ca-certificates bash git openssl unzip wget && \
    rm -rf /var/cache/apk/* && \
    cd /tmp && \
    wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/bin && \
    wget -O terraform-provider.zip https://releases.hashicorp.com/terraform-provider-azurerm/${TERRAFORM_AZURERM_PROVIDER_VERSION}/terraform-provider-azurerm_${TERRAFORM_AZURERM_PROVIDER_VERSION}_linux_amd64.zip && \
    unzip -d /usr/providers terraform-provider.zip && \
    cp /usr/providers/terraform-provider-azurerm_v${TERRAFORM_AZURERM_PROVIDER_VERSION}_x4 /usr/bin

#RUN  mkdir /usr/local/share/ca-certificates/extra

COPY cacert.pem /usr/local/share/ca-certificates/aacacert.pem

RUN update-ca-certificates

ENV http_proxy=http://nonprod.inetgw.aa.com:9093/ \
    https_proxy=http://nonprod.inetgw.aa.com:9093/ \
    no_proxy="artifacts.aa.com, nexusread.aa.com"

USER root

