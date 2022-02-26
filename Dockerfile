# pull base image
FROM alpine:3.15

ARG ANSIBLE_VERSION_ARG="2.12.1"
ENV ANSIBLE_VERSION ${ANSIBLE_VERSION_ARG}

# Labels.
LABEL maintainer="will@willhallonline.co.uk" \
    second-maintainer="Rivan" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.name="willhallonline/ansible" \
    org.label-schema.description="Ansible inside Docker" \
    org.label-schema.url="https://github.com/willhallonline/docker-ansible" \
    org.label-schema.vcs-url="https://github.com/willhallonline/docker-ansible" \
    org.label-schema.vendor="Will Hall Online" \
    org.label-schema.docker.cmd="docker run --rm -it -v $(pwd):/ansible ~/.ssh/id_rsa:/root/id_rsa willhallonline/ansible:2.11-alpine-3.14"

ADD requirements.txt .

RUN apk --no-cache add \
        sudo \
        python3\
        py3-pip \
        openssl \
        ca-certificates \
        sshpass \
        openssh-client \
        rsync \
        git && \
    apk --no-cache add --virtual build-dependencies \
        python3-dev \
        libffi-dev \
        musl-dev \
        gcc \
        cargo \
        openssl-dev \
        libressl-dev \
        build-base && \
    pip3 install --upgrade pip wheel boto boto3 && \
    pip3 install --upgrade cryptography cffi && \
    pip3 install ansible-core==${ANSIBLE_VERSION} ansible && \
    pip3 install mitogen ansible-lint jmespath && \
    pip3 install --upgrade pywinrm && \
    python3 -m pip install -r requirements.txt && \
    apk del build-dependencies && \
    rm -rf /var/cache/apk/* && \
    rm -rf /root/.cache/pip && \
    rm -rf /root/.cargo
    
RUN mkdir /ansible && \
    mkdir -p /etc/ansible && \
    echo 'localhost' > /etc/ansible/hosts && \
    ansible-galaxy collection install kubernetes.core && \
    ansible-galaxy collection install cloud.common

WORKDIR /ansible

CMD [ "ansible-playbook", "--version" ]