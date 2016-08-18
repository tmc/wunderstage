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

```sh
$ alias kc='kubectl --namespace=ci'
$ kc get po
$ kc port-forward (POD NAME) 8080
$ kc logs (POD NAME) ci-1-jenkins
```
