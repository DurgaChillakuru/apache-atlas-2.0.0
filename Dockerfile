ARG VERSION-2.0.0

FROM ubuntu:18.04
LABEL maintainer="dchillak@redhat.com"

ENV ATLAS_HOME=/opt/apache-atlas-2.0/apache-atlas-2.1.0-SNAPSHOT-server/apache-atlas-2.1.0-SNAPSHOT

RUN apt-get update
RUN apt-get -y install curl
    && apt-get -y install apt-utils \
    && apt-get -y install maven wget git python \
        openjdk-8-jdk-headless

RUN cd /tmp \
    && git clone https://github.com/apache/atlas.git -b branch-2.0 \
    && cd atlas-branch-2.0 \
    && export MAVEN_OPTS="-Xms2g -Xmx2g" \
    && export JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64" \
    && mvn clean -DskipTests package -Pdist,embedded-hbase-solr
    && cd distro/target \
    && tar -xzvf /tmp/atlas-branch-2.0/distro/target/apache-atlas-2.1.0-SNAPSHOT-server.tar.gz -C /opt/apache-atlas-2.0 \
    && sed '505,506d' $ATLAS_HOME/bin/atlas_config.py

EXPOSE 21000

ENV MANAGE_LOCAL_HBASE=true
ENV MANAGE_LOCAL_SOLR=true
ENV MANAGE_EMBEDDED_CASSANDRA=false
ENV MANAGE_LOCAL_ELASTICSEARCH=false

COPY conf/atlas-application.properties /opt/apache-atlas-2.0/apache-atlas-2.1.0-SNAPSHOT-server/apache-atlas-2.1.0-SNAPSHOT/conf/atlas-application.properties

CMD ["/bin/bash", "-c", "/opt/apache-atlas-2.0/apache-atlas-2.1.0-SNAPSHOT-server/apache-atlas-2.1.0-SNAPSHOT/bin/atlas_start.py; tail -fF /apache-atlas-2.0.0/logs/application.log"]