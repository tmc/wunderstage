Wunderstage
===========

Cloud Native Continuous Integration

Installing wunderstage is comprised of three stages:

* stage0 - provisions a Kubernetes cluster.
* stage1 - builds necessary images.
* stage2 - installs PaaS framework (Deis).
* stage3 - installs Jenkins.

These commands are designed to be run withing a Google Cloud Shell for maximum simplicity but can be adapted for other Kubernetes environments.

## Stage 0

* **Skip if**: you already have a Kubernetes cluster provisioned.
* **Prerequisites**: `gcloud` command set up.

```sh
$ make stage0 
```

* **Verification**: `kubectl get po` runs successfully.

## Stage 1

* **Prerequisites**: Kubernetes cluster configured and `kubectl` configured correctly.
```sh
$ make stage1
```

## Stage 2
```sh
$ make stage2
```

## Stage 3
```sh
$ make stage3
```

### Configuring Jenkins

At this point you should have your jenkins pod coming up.

Let's check the status:

First we'll define a handy alias that reduces typing:
```sh
$ alias kc='kubectl --namespace=ci'
```

Now let's check the status of the pod:
```sh
$ kc get po
```

You should see something similar to:
```
NAME                            READY     STATUS              RESTARTS   AGE
ci-1-jenkins-3866958816-tnm1a   0/3       ContainerCreating   0          9s
```

Wait a bit then run again:
```
ci-1-jenkins-3866958816-tnm1a   3/3       Running   0         2m
```

Great! we're up and running. Let's configure jenkins by finding the public ingress address:
```
kc describe svc ci-1-proxy |grep Ingress
```

Visit that URL in a web browser.

To obtain the admin password we need to check stdout of the jenkins container:

Let's set the pod name so we dont' have to re-type it:
```
$ POD=<POD NAME from `kc get po` output>
$ kc logs ${POD} jenkins
```

### Getting on production domain

The bootstrapping process creates a self-signed certificate. Let's replace that with a certificate that is valid and matches our

#### Configure Github integration

To have activity on github automatically trigger builds we need to configure the github integration.

Create a GitHub user that has read access to relevant repositories.

Create a personal access token with the following scopes: **admin:repo_hook, repo, repo:status**.

There are some alternatives here but for simplicity we'll employ Automatic Mode in which Jenkins manages hooks for us.

See https://wiki.jenkins-ci.org/display/JENKINS/GitHub+Plugin for details.

Steps:
1. Walk through setup wizard and create an admin user.
2. Enable proxy compatiblity under `Manage Jenkins` -> `Configure Security`
3. `Manage Jenkins` -> `Configure System` -> `GitHub` -> `GitHub Servers` -> `Add GitHub Server`
4. `Credentials` -> `Add` -> `Jenkins` -> `Username with password`
