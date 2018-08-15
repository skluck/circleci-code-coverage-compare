FROM php:7.2.8-cli-alpine3.7

RUN apk add \
    sudo openssh-client ca-certificates \
    tar gzip unzip zip bzip2 curl \
    bash bc shadow

# Set timezone to UTC by default
RUN ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime

RUN JQ_DOWNLOAD_URL="https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64" \
    && curl -sSLk --output /usr/bin/jq "${JQ_DOWNLOAD_URL}" \
    && chmod +x /usr/bin/jq \
    && jq --version

# https://github.com/circleci/circleci-images/blob/staging/shared/images/Dockerfile-basic.template#L69
RUN groupadd --gid 3434 circleci \
  && useradd --uid 3434 --gid circleci --shell /bin/bash --create-home circleci \
  && echo 'circleci ALL=NOPASSWD: ALL' >> /etc/sudoers.d/50-circleci \
  && echo 'Defaults    env_keep += "DEBIAN_FRONTEND"' >> /etc/sudoers.d/env_keep

COPY generate-total-coverage.sh             /usr/bin/generate-total-coverage
COPY generate-total-coverage.php            /usr/bin/generate-total-coverage.php
COPY fetch-target-sha.sh                    /usr/bin/fetch-target-sha
COPY ensure-code-coverage-is-increased.sh   /usr/bin/ensure-code-coverage-is-increased

USER circleci

CMD ["/bin/sh"]
