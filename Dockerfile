FROM ubuntu:bionic

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update && apt-get install -y --no-install-recommends \
    g++ \
    make \
    python \
    software-properties-common \
    build-essential \
    libssl-dev \
    libc6-dev \
    g++-multilib \
    unzip \
    git \ \
    wget \
    curl \
    bsdmainutils \
    automake \
    libminiupnpc-dev \
    jq \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/Arrowchain/arrow.git
WORKDIR /arrow
RUN git checkout master && \
  ./zcutil/fetch-params.sh

ARG ARROW_VERSION=1.1.0

RUN mkdir -p /arrow-bins
WORKDIR /arrow-bins
RUN wget -qO- https://github.com/Arrowchain/arrow/releases/download/${ARROW_VERSION}/arrow-v${ARROW_VERSION}-ubuntu-18.04.tar.gz | tar xvz -C /arrow-bins
RUN chmod +x /arrow-bins/arrowd
RUN chmod +x /arrow-bins/arrow-cli
RUN ln -sf /arrow-bins/arrowd /usr/bin/arrowd
RUN ln -sf /arrow-bins/arrow-cli /usr/bin/arrow-cli

RUN mkdir -p /arrow-conf
COPY arrow.conf /arrow-conf/arrow.conf
RUN mkdir -p /scripts
COPY wallet_management.sh /scripts/wallet_management.sh
COPY config.json /scripts/config.json
RUN chmod +x /scripts/wallet_management.sh

#PORT 7654 is P2P, 6543 is RPC
EXPOSE 7654 6543

VOLUME /root/.arrow

# CMD tail -f /dev/null
ENTRYPOINT ["./scripts/wallet_management.sh", "-f", "/scripts/config.json"]
