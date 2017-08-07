FROM registry.access.redhat.com/rhel7:latest
#FROM registry.paas.redhat.com/itpaas-blessed-images/rhel7-platops

MAINTAINER RHT Ambassadors <rh-labs-ambassadors@redhat.com>

RUN yum repolist --disablerepo=* && \
    yum-config-manager --disable \* > /dev/null && \
    yum-config-manager --enable rhel-7-server-rpms > /dev/null

RUN yum update -y \
  && yum install -y telnet postgresql unzip curl tar java-1.8.0-openjdk.x86_64 gnupg2 \
  && yum clean all \
  && rm -rf /var/cache/yum

# configure java runtime
ENV JAVA_HOME=/usr/lib/jvm/jre-openjdk \
  SONAR_VERSION=6.4 \
  SONARQUBE_HOME='/home/sonar' \
  SONARQUBE_JDBC_USERNAME=sonar \
  SONARQUBE_JDBC_PASSWORD=sonar \
  SONARQUBE_USER=sonar \
  SONARQUBE_JDBC_URL=

RUN adduser -d $SONARQUBE_HOME -M -r -s /bin/bash -u 212 -U $SONARQUBE_USER

ADD D26468DE.asc /tmp/D26468DE.asc

RUN gpg --import /tmp/D26468DE.asc \
    && cd /home \
    && curl -o /tmp/sonarqube.zip -fSL https://sonarsource.bintray.com/Distribution/sonarqube/sonarqube-$SONAR_VERSION.zip \
    && curl -o /tmp/sonarqube.zip.asc -fSL https://sonarsource.bintray.com/Distribution/sonarqube/sonarqube-$SONAR_VERSION.zip.asc \
    && gpg --batch --verify /tmp/sonarqube.zip.asc /tmp/sonarqube.zip \
    && unzip -d /home /tmp/sonarqube.zip \
    && mv /home/sonarqube-$SONAR_VERSION $SONARQUBE_HOME \
    && rm -f /tmp/sonarqube.zip* \
    && rm -rf $SONARQUBE_HOME/bin/*

VOLUME "$SONARQUBE_HOME/data"

WORKDIR $SONARQUBE_HOME

ADD sonar.properties $SONARQUBE_HOME/conf/sonar.properties

ADD run.sh $SONARQUBE_HOME/bin/run.sh

CMD $SONARQUBE_HOME/bin/run.sh

RUN cp -a $SONARQUBE_HOME/data $SONARQUBE_HOME/data-init && \
    cp -a $SONARQUBE_HOME/extensions $SONARQUBE_HOME/extensions-init

ADD plugins.sh $SONARQUBE_HOME/bin/plugins.sh

RUN $SONARQUBE_HOME/bin/plugins.sh pmd gitlab github ldap

RUN chown -R $SONARQUBE_USER:$SONARQUBE_USER $SONARQUBE_HOME

RUN chmod 777 $SONARQUBE_HOME/data

ENTRYPOINT ["./bin/run.sh"]

# Http port
EXPOSE 9000

USER 212
