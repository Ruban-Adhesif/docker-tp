FROM alpine:latest

RUN apk add --no-cache \
    ansible \
    openssh-client \
    python3 \
    py3-pip \
    docker-cli \
    && pip3 install --upgrade pip \
    && pip3 install docker \
    && ansible-galaxy collection install community.docker

WORKDIR /ansible

CMD ["ansible-playbook", "--help"]
