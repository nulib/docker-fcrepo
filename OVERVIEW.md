# Fedora Repository

[![Docker Pulls](https://img.shields.io/docker/pulls/samvera/fcrepo4.svg?maxAge=604800)](https://hub.docker.com/r/samvera/fcrepo4)

This Docker repository contains tagged images for [Fedora](https://wiki.duraspace.org/display/FF/Fedora+Repository+Home) [releases](https://github.com/fcrepo4/fcrepo4/releases) from v4.7.0 onward.

## Usage

To run a generic Fedora server with an ephemeral datastore and the same default, unsecured configuration
as the “one-click” test configuration:

```bash
docker run -ti -p 8080:8080 samvera/fcrepo4:VERSION
```

e.g.:

```bash
docker run -ti -p 8080:8080 samvera/fcrepo4:5.1.0
```

### Overriding Default Configuration

The container's startup script will recursively copy anything in `/jetty-overrides` to
`/var/lib/jetty`, providing access to Jetty's full range of configuration options without
rebuilding the container. Simply mount the new configuration like so:

```bash
docker run -ti -p 8080:8080 \
  -v /path/to/my/configs:/jetty-overrides \
  samvera/fcrepo4:5.1.0
```

For more information regarding Jetty configuration, see the
[Jetty Start Configuration Files](https://www.eclipse.org/jetty/documentation/9.4.x/quick-start-configure.html#_jetty_start_configuration_files)
section of the main Jetty documentation.

For an example configuration that adds basic authentication to Fedora's REST endpoints (using the
customary `fedoraAdmin:fedoraAdmin` user), see the example in [this project's github repo](https://github.com/nulib/docker-fcrepo/tree/master/examples/auth).

For more information on using Docker images and containers, see the
[Docker CLI documentation](https://docs.docker.com/engine/reference/commandline/cli/).
