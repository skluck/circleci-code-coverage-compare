FROM circleci/php:7.2.8-cli-stretch

USER root

ENV JQ_DOWNLOAD_URL "https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64"

RUN curl -sSL \
    -o /usr/bin/jq \
    "${JQ_DOWNLOAD_URL}" \
        \
        && \
    chmod +x /usr/bin/jq \
        \
        && \
    apt-get install bc

USER circleci
