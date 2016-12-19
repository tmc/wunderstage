FROM jenkinsci/jenkins:latest

# preinstall plugins
USER root
RUN apt-get update
RUN apt-get install -y build-essential
RUN apt-get install -y apt-transport-https ca-certificates
RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
RUN echo 'deb https://apt.dockerproject.org/repo debian-jessie main' > /etc/apt/sources.list.d/docker.list
RUN apt-get update
RUN apt-get install -y docker-engine=1.9.1-0~jessie # version on gce at time of writing
RUN gpasswd -a jenkins docker

ENV DEIS_VERSION stable
ENV KUBECTL_VERSION v1.4.5
ENV HELM_VERSION v2.0.0
ENV HELMC_VERSION 0.8.1%2Be4b3983

RUN wget https://storage.googleapis.com/workflow-cli-release/deis-${DEIS_VERSION}-linux-amd64; mv deis-${DEIS_VERSION}-linux-amd64 /usr/local/bin/deis; chmod +x /usr/local/bin/deis
RUN wget https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl; mv kubectl /usr/local/bin/kubectl; chmod +x /usr/local/bin/kubectl
RUN wget https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz; tar xf ./helm-${HELM_VERSION}-linux-amd64.tar.gz; mv linux-amd64/* /usr/local/bin/
RUN wget https://bintray.com/deis/helm/download_file?file_path=helmc-${HELMC_VERSION}-linux-amd64.zip && unzip *helm*.zip; mv helmc /usr/local/bin/helmc

RUN /usr/local/bin/install-plugins.sh github-organization-folder github-oauth ssh-agent ansicolor lockable-resources slack
COPY custom.groovy /usr/share/jenkins/ref/init.groovy.d/custom.groovy

# TODO(tmc) run dind docker in separate container?
#ENV DOCKER_HOST localhost:237
#USER jenkins
#ENTRYPOINT ["/bin/tini", "--", "/usr/local/bin/jenkins.sh"]
ADD entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/bin/tini", "--", "/usr/local/bin/entrypoint.sh"]

