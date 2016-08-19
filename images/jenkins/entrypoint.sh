#!/bin/sh
ssh-keyscan -p 2222 ${DEIS_BUILDER},$(getent hosts ${DEIS_BUILDER} | awk '{ print $1 }') > /root/.ssh/known_hosts
mkdir ~jenkins/.ssh || echo
cp /root/.ssh/known_hosts ~jenkins/.ssh/known_hosts
chown -R jenkins:jenkins ~jenkins/.ssh
2>&1
exec /usr/local/bin/jenkins.sh
