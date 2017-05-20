FROM sonarqube:latest
MAINTAINER Deven Phillips <deven.phillips@redhat.com>

ARG SONAR_PLUGINS_LIST=local
ENV SONAR_PLUGINS_LIST ${SONAR_PLUGINS_LIST}
RUN cp -a /opt/sonarqube/data /opt/sonarqube/data-init
RUN cp -a /opt/sonarqube/extensions /opt/sonarqube/extensions-init
RUN chown 65534:0 /opt/sonarqube && chmod -R gu+rwX /opt/sonarqube
ADD plugins.sh /opt/sonarqube/bin/plugins.sh
RUN /opt/sonarqube/bin/plugins.sh ${SONAR_PLUGINS_LIST}
ADD run.sh /opt/sonarqube/bin/run.sh
CMD /opt/sonarqube/bin/run.sh