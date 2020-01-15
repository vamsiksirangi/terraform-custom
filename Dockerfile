ARG TERRAFORM_VERSION=0.11.7
ARG TERRAFORM_PROVIDER_VERSION=1.39.0

ARG JENKINS_USER="10011"
ARG JENKINS_USERNAME="cicduser"

# For caching purposes
FROM alpine as providers

RUN ls -lrt /
RUN mkdir -p /usr/providers

# Add providers here
RUN wget -O terraform-1.39.0.zip https://releases.hashicorp.com/terraform-provider-azurerm/1.39.0/terraform-provider-azurerm_1.39.0_linux_amd64.zip && \
    unzip -d /usr/providers terraform-1.39.0.zip
RUN ls -lrt /usr/providers

# Add them to hashicorp/terraform image
FROM hashicorp/terraform:0.12.18


COPY --from=providers /usr/providers/terraform-provider-azurerm_v1.39.0_x4 /bin/

WORKDIR /app
ENV http_proxy=http://nonprod.inetgw.aa.com:9093/ \
  https_proxy=http://nonprod.inetgw.aa.com:9093/ \
  no_proxy="artifacts.aa.com, nexusread.aa.com"
