FROM alpine:3.11.2

ENV TERRAFORM_VERSION=0.12.12

ARG JENKINS_USER="10011"
ARG JENKINS_USERNAME="cicduser"

RUN addgroup -g $JENKINS_USER $JENKINS_USERNAME && \
    adduser -D -u $JENKINS_USER -G $JENKINS_USERNAME -g '' $JENKINS_USERNAME && \
    echo "$JENKINS_USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

COPY cacert.pem /home/${JENKINS_USERNAME}/cacerts/cacert.pem
#
RUN mkdir /usr/providers

RUN apk update && \
    apk add curl bash ca-certificates git openssl unzip wget && \
    cd /tmp && \
    wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/bin && \
    wget -O terraform-1.39.0.zip https://releases.hashicorp.com/terraform-provider-azurerm/1.39.0/terraform-provider-azurerm_1.39.0_linux_amd64.zip && \
    unzip -d /usr/providers terraform-1.39.0.zip

RUN cp /usr/providers/terraform-provider-azurerm_v1.39.0_x4 /usr/bin

ENV http_proxy=http://nonprod.inetgw.aa.com:9093/ \
    https_proxy=http://nonprod.inetgw.aa.com:9093/ \
    no_proxy="artifacts.aa.com, nexusread.aa.com"

USER root
