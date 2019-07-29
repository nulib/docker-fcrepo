FROM        jetty:jre8
ARG         FCREPO_VERSION=""
RUN         bash -c 'if [[ "$FCREPO_VERSION" < "4.7" ]]; then echo "Cannot build fcrepo4 v${FCREPO_VERSION}"; exit 1; fi'
ARG         FEDORA_LOCATION=https://github.com/fcrepo4/fcrepo4/releases/download/fcrepo-${FCREPO_VERSION}/fcrepo-webapp-${FCREPO_VERSION}.war
ADD         ${FEDORA_LOCATION} ${JETTY_BASE}/fedora/fedora.war
ADD         assets/fedora.xml ${JETTY_BASE}/webapps/fedora.xml
ADD         assets/jetty.xml ${JETTY_HOME}/etc/jetty.xml
ADD         assets/override-web.xml ${JETTY_BASE}/fedora/override-web.xml
USER        root
ENV         FEDORA_ADMIN_USER=fedoraAdmin FEDORA_ADMIN_PASS=fedoraAdmin
RUN         echo "${FEDORA_ADMIN_USER}: MD5:$(echo -n ${FEDORA_ADMIN_PASS} | md5sum | awk '{ print $1 }'),fedoraAdmin" > ${JETTY_BASE}/fedora/fcrepo-realm.properties
RUN         mkdir -p /data
RUN         /bin/chown -R jetty:jetty ${JETTY_BASE}/fedora/
EXPOSE      8080 61613 61616
ADD         assets/fedora-entrypoint.sh /
ENTRYPOINT  "/fedora-entrypoint.sh"
HEALTHCHECK --interval=30s --timeout=5s \
  CMD curl -X OPTIONS -u ${FEDORA_ADMIN_USER}:${FEDORA_ADMIN_PASS} -f http://localhost:8080/rest || exit 1
