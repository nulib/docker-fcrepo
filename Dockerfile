FROM        openjdk:8 as warfile
ARG         FCREPO_VERSION=""
RUN         mkdir -p /build/unpack
WORKDIR     /build/unpack
ADD         assets/repack.sh .
RUN         ./repack.sh

FROM        jetty:jre8-alpine
USER        root
RUN         apk update && apk add bash
RUN         mkdir -p /data ${JETTY_BASE}/etc ${JETTY_BASE}/modules
COPY        --chown=jetty:jetty --from=warfile /build/fedora.war ${JETTY_BASE}/fedora/fedora.war
COPY        --chown=jetty:jetty --from=warfile /build/unpack/WEB-INF/web.xml ${JETTY_BASE}/fedora/override-web.xml
ADD         --chown=jetty:jetty assets/fedora.xml ${JETTY_BASE}/webapps/fedora.xml
RUN         /bin/chown -R jetty:jetty ${JETTY_BASE}/fedora/
EXPOSE      8080 61613 61616
ADD         assets/fedora-entrypoint.sh /
ARG         FCREPO_VERSION
ENV         FCREPO_VERSION=${FCREPO_VERSION}
ENTRYPOINT  "/fedora-entrypoint.sh"
HEALTHCHECK --interval=30s --timeout=5s \
  CMD curl -X OPTIONS -u ${FEDORA_ADMIN_USER}:${FEDORA_ADMIN_PASS} -f http://localhost:8080/rest || exit 1
