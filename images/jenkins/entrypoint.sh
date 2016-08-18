#!/bin/sh
mkdir ~jenkins/.ssh || echo
touch ~jenkins/.ssh/known_hosts
chown -R jenkins:jenkins ~jenkins/.ssh
ssh-keyscan -p 2222 -H ${DEIS_BUILDER} >> ~jenkins/.ssh/known_hosts || echo 'issue adding'
2>&1
exec /usr/local/bin/jenkins.sh
