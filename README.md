WunderStage
===========

Cloud Native Continuous Integration


```sh
$ make stage0 
```
```sh
$ make stage1
```
```sh
$ make stage2
```

## Configuring Jenkinso

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
