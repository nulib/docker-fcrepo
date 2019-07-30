#!/bin/bash

echo "Changing ownership of /data as $(whoami)"
chown jetty:jetty /data
echo "Downgrading privileges and resuming"

for MEM_FILE in memory.limit_in_bytes memory.memsw.limit_in_bytes memory.kmem.limit_in_bytes; do
  if [[ -e /sys/fs/cgroup/memory/${MEM_FILE} ]]; then
    break
  fi
done

if [[ ! -e /sys/fs/cgroup/memory/${MEM_FILE} ]]; then
  echo "Could not read container memory. Exiting."
  exit 1
fi

if [[ -d /jetty-overrides ]]; then
  cd /jetty-overrides
  for file in $(find . -type f); do cp $file ${JETTY_BASE}/$file; done
  cd -
fi

MEM_BYTES=$(cat /sys/fs/cgroup/memory/${MEM_FILE})
if [[ $MEM_BYTES -ne "9223372036854771712" ]]; then
  let "MX=$MEM_BYTES * 8 / 10 / 1024 / 1024"
  echo "Setting -Xmx${MX}m"
  JAVA_OPTIONS="${JAVA_OPTIONS} -Xmx${MX}m"
fi

DEFAULT_CONFIG="file-simple"
if [[ "$FCREPO_VERSION" < "4.7.0" ]]; then
  DEFAULT_CONFIG="minimal-default"
fi

MODESHAPE_CONFIG=${MODESHAPE_CONFIG:-classpath:/config/${DEFAULT_CONFIG}/repository.json}
export JAVA_OPTIONS="${JAVA_OPTIONS} -Dfcrepo.home=/data -Dfcrepo.modeshape.configuration=${MODESHAPE_CONFIG}"
su -s /bin/ash -c "exec /docker-entrypoint.sh $@" jetty
