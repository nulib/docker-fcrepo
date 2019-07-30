FROM        openjdk:8 as warfile
ARG         FCREPO_VERSION=""
RUN         bash -c 'if [[ "$FCREPO_VERSION" < "4.7" ]]; then echo "Cannot build fcrepo4 v${FCREPO_VERSION}"; exit 1; fi'
RUN         mkdir -p /build/unpack
WORKDIR     /build/unpack
ADD         https://github.com/fcrepo4/fcrepo4/releases/download/fcrepo-${FCREPO_VERSION}/fcrepo-webapp-${FCREPO_VERSION}.war /build/fedora.war
RUN         jar -xf ../fedora.war
ADD         https://raw.githubusercontent.com/fcrepo4/fcrepo4/fcrepo-${FCREPO_VERSION}/fcrepo-webapp/src/main/jetty-console/WEB-INF/web.xml WEB-INF/web.xml
RUN         jar -cf ../fedora.war .

FROM        jetty:jre8
COPY        --from=warfile /build/fedora.war ${JETTY_BASE}/fedora/fedora.war
COPY        --from=warfile /build/unpack/WEB-INF/web.xml ${JETTY_BASE}/fedora/override-web.xml
ADD         assets/fedora.xml ${JETTY_BASE}/webapps/fedora.xml
USER        root
RUN         mkdir -p /data ${JETTY_BASE}/etc ${JETTY_BASE}/modules
RUN         /bin/chown -R jetty:jetty ${JETTY_BASE}/fedora/
EXPOSE      8080 61613 61616
ADD         assets/fedora-entrypoint.sh /
ENTRYPOINT  "/fedora-entrypoint.sh"
HEALTHCHECK --interval=30s --timeout=5s \
  CMD curl -X OPTIONS -u ${FEDORA_ADMIN_USER}:${FEDORA_ADMIN_PASS} -f http://localhost:8080/rest || exit 1
