FROM python:3.6-alpine

LABEL description="ElastAlert suitable for Kubernetes and Helm"
LABEL maintainer="Jason Ertel (jertel at codesim.com)"

ARG ELASTALERT_VERSION=0.2.1

RUN apk --update upgrade && \
    # apk add ca-certificates gcc libffi-dev musl-dev python3==3.6.8-r0 python3-dev==3.6.8-r0 openssl openssl-dev tzdata file-dev && \
    apk add ca-certificates gcc libffi-dev musl-dev openssl openssl-dev tzdata file-dev && \
    rm -rf /var/cache/apk/*

RUN wget https://github.com/Yelp/elastalert/archive/v${ELASTALERT_VERSION}.zip -O /tmp/elastalert.zip && \
    unzip /tmp/elastalert.zip -d /opt && \
    rm -f /tmp/elastalert.zip && \
    mv /opt/elastalert-${ELASTALERT_VERSION} /opt/elastalert && \
    cd /opt/elastalert && \
    # sed -i '/jira/d' requirements.txt && \
    pip3 install elasticsearch && \
    pip3 install urllib3 && \
    # pip3 install jira==2.0.0 && \
    python3 setup.py install && \
    pip3 install -e . && \
    apk del gcc libffi-dev musl-dev openssl-dev

RUN mkdir -p /opt/elastalert/config && \
    mkdir -p /opt/elastalert/rules && \
    echo "#!/bin/sh" >> /opt/elastalert/run.sh && \
    echo "elastalert-create-index --config /opt/config/elastalert_config.yaml" >> /opt/elastalert/run.sh && \
    echo "elastalert --config /opt/config/elastalert_config.yaml \"\$@\"" >> /opt/elastalert/run.sh && \
    chmod +x /opt/elastalert/run.sh

VOLUME [ "/opt/config", "/opt/rules" ]
WORKDIR /opt/elastalert
ENTRYPOINT ["/opt/elastalert/run.sh"]
