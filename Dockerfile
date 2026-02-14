# 젠킨스 최신 LTS 버전 사용
FROM jenkins/jenkins:lts

USER root

# 1. Java 21 설치 (Debian 계열 베이스 기준)
# 젠킨스 기본 이미지에 포함된 Java 외에 빌드용 Java 21을 추가 설치합니다.
RUN apt-get update && apt-get install -y \
    openjdk-21-jdk \
    python3 \
    python3-pip \
    python3-venv \
    && apt-get clean

# 2. 환경 변수 설정
# JAVA_HOME을 21 버전으로 고정하여 Gradle이나 Maven이 이 버전을 쓰게 합니다.
ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV PATH=$PATH:$JAVA_HOME/bin

# 3. 플러그인 설치
RUN jenkins-plugin-cli --plugins configuration-as-code git workflow-aggregator mattermost-notifier

USER jenkins
