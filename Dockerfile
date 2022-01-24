FROM        openjdk:8 as warfile
RUN         mkdir -p /build /unpack
WORKDIR     /unpack
ADD         assets/repack.sh .
ARG         FCREPO_VERSION
RUN         bash ./repack.sh

FROM        jetty:9-jre8
USER        root
RUN         mkdir -p /data ${JETTY_BASE}/etc ${JETTY_BASE}/modules
ADD         assets/fedora-entrypoint.sh /
ADD         --chown=jetty:jetty assets/fedora.xml ${JETTY_BASE}/webapps/fedora.xml
EXPOSE      8080 61613 61616
ENTRYPOINT  "/fedora-entrypoint.sh"
ARG         FCREPO_VERSION
ENV         FCREPO_VERSION=${FCREPO_VERSION}
COPY        --chown=jetty:jetty --from=warfile /build/* ${JETTY_BASE}/fedora/
