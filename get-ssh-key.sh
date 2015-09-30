#!/bin/bash
ATTEMPTS=10

mkdir -p /root/.ssh
chmod 700 /root/.ssh

TMPFILE=$(mktemp)
while [ ${ATTEMPTS} -gt 0 ]; do
  ATTEMPTS=$((${ATTEMPTS}-1))
  rm -f ${TMPFILE}
  [ -f /root/.ssh/authorized_keys ] && cat /root/.ssh/authorized_keys > ${TMPFILE}
  curl -m 5 -s http://169.254.169.254/latest/meta-data/public-keys/0/openssh-key \
    >> ${TMPFILE} 2>/dev/null
  if [ $? -eq 0 ]; then
    cat ${TMPFILE} >> /root/.ssh/authorized_keys
    chmod 0600 /root/.ssh/authorized_keys
    echo "Successfully retrieved public key from instance metadata"
    echo "********************************************************"
    echo "AUTHORIZED KEYS"
    echo "********************************************************"
    cat /root/.ssh/authorized_keys
    echo
    echo "********************************************************"
    break
  fi
done
rm -f ${TMPFILE}
