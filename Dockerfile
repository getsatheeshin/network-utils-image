FROM ubuntu:bionic

RUN apt-get update \
  && apt-get install --no-install-recommends --yes --force-yes \
    locales \
    bind9-host \
    curl \
    dnsutils \
    httpie \
    iputils-ping \
    jq \
    netcat-openbsd \
    mongodb-clients \
    mysql-client \
    net-tools \
    postgresql-client \
    redis-tools \
    swaks \
    telnet \
    traceroute \
    vim \
    nano \
    wget \
    influxdb-client \
    rabbitmq-server \
    python-setuptools \
    python-pip \
    openssh-client \
    p7zip-full \
    iproute2 \
  && rm -rf /var/lib/apt/lists/*

RUN curl -O https://raw.githubusercontent.com/rabbitmq/rabbitmq-management/v3.7.14/bin/rabbitmqadmin \
  && mv rabbitmqadmin /usr/local/bin/ \
  && chmod +x /usr/local/bin/rabbitmqadmin

RUN pip install cqlsh

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
RUN curl -O https://storage.googleapis.com/hey-release/hey_linux_amd64 \
  && mv hey_linux_amd64 /usr/local/bin/hey \
  && chmod +x /usr/local/bin/hey

###CMD [ "sh", "-c", "while true; do ping 8.8.8.8; done" ]

### Setup user for build execution and application runtime
ENV APP_ROOT=/opt/app-root
ENV PATH=${APP_ROOT}/bin:${PATH} HOME=${APP_ROOT}
COPY bin/ ${APP_ROOT}/bin/
RUN chmod -R u+x ${APP_ROOT}/bin && \
    chgrp -R 0 ${APP_ROOT} && \
    chmod -R g=u ${APP_ROOT} /etc/passwd

### Containers should NOT run as root as a good practice
USER 10001
WORKDIR ${APP_ROOT}

### user name recognition at runtime w/ an arbitrary uid - for OpenShift deployments
ENTRYPOINT [ "uid_entrypoint.sh" ]
CMD run.sh
