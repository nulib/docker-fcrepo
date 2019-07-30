#!/bin/bash

echo "Downloading Fedora v${FCREPO_VERSION} .war file"
curl -# -Lo /build/fedora.war https://github.com/fcrepo4/fcrepo4/releases/download/fcrepo-${FCREPO_VERSION}/fcrepo-webapp-${FCREPO_VERSION}.war
echo "Extracting Fedora v${FCREPO_VERSION} .war file"
jar -xf /build/fedora.war

curl --silent -I https://raw.githubusercontent.com/fcrepo4/fcrepo4/fcrepo-${FCREPO_VERSION}/fcrepo-webapp/src/main/jetty-console/WEB-INF/web.xml \
  | head -1 \
  | grep "200 OK" > /dev/null

if [[ $? == 0 ]]; then
  echo "Downloading Fedora v${FCREPO_VERSION} one-click web.xml"
  curl -# -Lo WEB-INF/web.xml https://raw.githubusercontent.com/fcrepo4/fcrepo4/fcrepo-${FCREPO_VERSION}/fcrepo-webapp/src/main/jetty-console/WEB-INF/web.xml
  echo "Repacking Fedora v${FCREPO_VERSION} .war file"
  jar -cf /build/fedora.war .
fi
cp WEB-INF/web.xml /build/override-web.xml