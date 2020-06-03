FROM ubuntu:18.04
LABEL maintainer="cdurga1494@gmail.com"

ARG VERSION=2.0.0

ENV ATLAS_HOME=/home/apache-atlas-${VERSION}/apache-atlas-${VERSION}
ENV MAVEN_OPTS="-Xms2g -Xmx2g"
ENV JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"
ENV MANAGE_LOCAL_HBASE=true
ENV MANAGE_LOCAL_SOLR=true
ENV MANAGE_EMBEDDED_CASSANDRA=false
ENV MANAGE_LOCAL_ELASTICSEARCH=false

RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get -y install apt-utils \
    && apt-get -y install \
    && apt-get -y install curl maven wget git python openjdk-8-jdk-headless patch \
    && cd /tmp \
    && wget http://mirror.linux-ia64.org/apache/atlas/${VERSION}/apache-atlas-${VERSION}-sources.tar.gz \
    && mkdir /tmp/atlas \
    && tar --strip 1 -xzvf apache-atlas-${VERSION}-sources.tar.gz -C /tmp/atlas \
    && rm apache-atlas-${VERSION}-sources.tar.gz \
    && cd /tmp/atlas \
    && sed -i 's/http:\/\/repo1.maven.org\/maven2/https:\/\/repo1.maven.org\/maven2/g' pom.xml \
    && wget --no-check-certificate https://github.com/apache/atlas/pull/20.patch \
    && git apply ./20.patch \
    && mvn clean -DskipTests package -Pdist,embedded-hbase-solr \
    && cd /tmp/atlas/distro/target \
    && mkdir /home/apache-atlas-${VERSION} \		
    && tar -xzvf /tmp/atlas/distro/target/apache-atlas-${VERSION}-server.tar.gz -C /home/apache-atlas-${VERSION}/ \
    && echo "after unzip /opt/apache-atlas-2.0.0 contents" \
    && echo "------------------------------------------------------------" \
    && ls /home/apache-atlas-${VERSION} \
    && rm -Rf /tmp/atlas \
    && apt-get -y --purge remove \
        maven \
        git \
    && apt-get clean \
    && sed '496,497d' ${ATLAS_HOME}/bin/atlas_config.py \
    && mkdir -p ${ATLAS_HOME}/logs

COPY atlas_start.py.patch atlas_config.py.patch ${ATLAS_HOME}/bin/
COPY atlas-application.properties ${ATLAS_HOME}/conf/atlas-application.properties
COPY Entrypoint.sh {ATLAS_HOME}/Entrypoint.sh

RUN cd ${ATLAS_HOME}/bin \
    && patch -b -f < atlas_start.py.patch \
    && patch -b -f < atlas_config.py.patch

EXPOSE 21000

VOLUME ["/home/apache-atlas-2.0.0/apache-atlas-2.0.0/conf", "/home/apache-atlas-2.0.0/apache-atlas-2.0.0/logs"]

CMD ["/bin/bash", "-c", "chmod 755 atlas-entrypoint.sh && ./atlas-entrypoint.sh", "/home/apache-atlas-2.0.0/apache-atlas-2.0.0/bin/atlas_start.py; tail -fF /home/apache-atlas-2.0.0/apache-atlas-2.0.0/logs/application.log"]
