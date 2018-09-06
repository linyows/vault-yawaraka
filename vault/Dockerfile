FROM linyows/consul:1.2-agent

ENV VAULT_VERSION 0.10.3
ENV VAULT_SHA256 ffec1c201f819f47581f54c08653a8d17ec0a6699854ebd7f6625babb9e290ed
ENV VAULT_ADDR https://127.0.0.1:8200
ENV VAULT_SKIP_VERIFY true
ENV COMMON_NAME vault.service.consul

RUN curl -sSL https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip \
    -o /tmp/vault.zip && \
    echo "${VAULT_SHA256}  /tmp/vault.zip" > /tmp/vault.sha256 && \
    sha256sum -c /tmp/vault.sha256 && \
    cd /bin && \
    unzip /tmp/vault.zip && \
    chmod +x /bin/vault && \
    rm /tmp/vault.zip /tmp/vault.sha256

COPY reload_vault.sh /etc/consul-template.d/reload_vault
COPY consul-template.conf /etc/consul-template.conf
COPY vault.ini /etc/supervisor.d/vault.ini
COPY vault.conf /etc/vault.conf

RUN chmod +x /etc/consul-template.d/* && \
    mkdir /etc/vault.d && cd /etc/vault.d && \
    openssl req -x509 -days 1 -newkey rsa:2048 -nodes \
    -out tls.crt -keyout tls.key -subj "/C=/ST=/L=/O=/OU=/CN=$COMMON_NAME"

EXPOSE 8125 8200 8301 8301/udp
