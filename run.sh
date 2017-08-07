#!/bin/bash

SONAR_HOME='/home/sonar'

set -x
set -e

## If the mounted data volume is empty, populate it from the default data
if ! [[ "$(ls -A $SONAR_HOME/data)" ]]; then
    cp -a $SONAR_HOME/data-init $SONAR_HOME/data
fi

## If the mounted extensions volume is empty, populate it from the default data
if ! [[ -d $SONAR_HOME/data/plugins ]]; then
	cp -a $SONAR_HOME/extensions-init/plugins $SONAR_HOME/data/plugins
        
fi

## Link the plugins directory from the mounted volume
rm -rf $SONAR_HOME/extensions/plugins
ln -s $SONAR_HOME/data/plugins $SONAR_HOME/extensions/plugins

if [ "${1:0:1}" != '-' ]; then
  exec "$@"
fi

#chown -R 0:0 $SONAR_HOME && chmod -R g+rwX $SONAR_HOME

set

java -jar lib/sonar-application-$SONAR_VERSION.jar \
    -Dsonar.web.javaAdditionalOpts="${SONARQUBE_WEB_JVM_OPTS} -Djava.security.egd=file:/dev/./urandom" \
    "$@"
