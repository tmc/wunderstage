#!/bin/sh
mkdir /root/.ssh || echo ok
ssh-keyscan -p 2222 -H ${DEIS_BUILDER} >> ~/.ssh/known_hosts || echo 'issue adding'
2>&1
exec /usr/local/bin/jenkins.sh
