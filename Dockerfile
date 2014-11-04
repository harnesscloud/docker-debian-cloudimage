FROM phusion/baseimage:latest
MAINTAINER Mark Stillwell <mark@stillwell.me>

# init script to get ssh key from metadata service
RUN mkdir -p /etc/my_init.d && \
    > /etc/my_init.d/05-setkey echo '#!/bin/bash\n\
ATTEMPTS=30\n\
\n\
mkdir -p /root/.ssh\n\
chmod 700 /root/.ssh\n\
\n\
TMPFILE=$(mktemp)\n\
while [ ! -f /root/.ssh/authorized_keys ] && [ ${ATTEMPTS} -gt 0 ]; do\n\
  ATTEMPTS=$((${ATTEMPTS}-1))\n\
  curl -sf http://169.254.169.254/latest/meta-data/public-keys/0/openssh-key\\\n\
    > ${TMPFILE} 2>/dev/null\n\
  if [ $? -eq 0 ]; then\n\
    cat ${TMPFILE} >> /root/.ssh/authorized_keys\n\
    chmod 0600 /root/.ssh/authorized_keys\n\
    echo "Successfully retrieved public key from instance metadata"\n\
    echo "********************************************************"\n\
    echo "AUTHORIZED KEYS"\n\
    echo "********************************************************"\n\
    cat /root/.ssh/authorized_keys\n\
    echo\n\
    echo "********************************************************"\n\
  fi\n\
done\n\
rm -f ${TMPFILE}\n' && \
    chmod 755 /etc/my_init.d/05-setkey
