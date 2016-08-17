FROM jenkinsci/jenkins:latest

# preinstall plugins
RUN /usr/local/bin/install-plugins.sh docker-slaves github-branch-source
COPY custom.groovy /usr/share/jenkins/ref/init.groovy.d/custom.groovy

USER root
RUN apt-get update
RUN apt-get install -y build-essential
RUN apt-get install -y apt-transport-https ca-certificates
RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
RUN echo 'deb https://apt.dockerproject.org/repo debian-jessie main' > /etc/apt/sources.list.d/docker.list
RUN apt-get update
RUN apt-get install -y docker-engine=1.9.1-0~jessie # version on gce at time of writing
RUN gpasswd -a jenkins docker
RUN wget https://storage.googleapis.com/workflow-cli/v2.1.0/deis-v2.1.0-linux-amd64; mv deis-v2.1.0-linux-amd64 /usr/local/bin/deis; chmod +x /usr/local/bin/deis
RUN wget https://storage.googleapis.com/kubernetes-release/release/v1.2.4/bin/linux/amd64/kubectl; mv kubectl /usr/local/bin/kubectl; chmod +x /usr/local/bin/kubectl
RUN wget https://bintray.com/deis/helm/download_file?file_path=helmc-0.8.1%2Be4b3983-linux-amd64.zip && unzip *helm*.zip; mv helmc /usr/local/bin/helmc

# TODO(tmc) run dind docker in separate container?
#ENV DOCKER_HOST localhost:237
#USER jenkins
#ENTRYPOINT ["/bin/tini", "--", "/usr/local/bin/jenkins.sh"]
ADD entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/bin/tini", "--", "/usr/local/bin/entrypoint.sh"]
