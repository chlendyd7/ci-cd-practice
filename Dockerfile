FROM jenkins/jenkins:lts
USER root

# 1. Java 21 및 필수 도구 설치
RUN apt-get update && apt-get install -y \
    openjdk-21-jdk \
    python3 \
    python3-pip \
    python3-venv \
    curl \
    gnupg \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 2. Docker CLI 설치
RUN curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh
RUN usermod -aG docker jenkins

# 3. 젠킨스 플러그인 설치
RUN jenkins-plugin-cli --plugins \
    configuration-as-code \
    git \
    workflow-aggregator \
    matrix-auth \
    mattermost \
    job-dsl \
    gitlab-plugin

USER jenkins