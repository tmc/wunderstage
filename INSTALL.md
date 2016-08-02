Installing Wunderstage
======================

Environment Variables:

* `REGISTRY` defaults to `gcr.io` 
* `PROJECT` defaults to `$(gcloud config list --format 'value(core.project)')`

These will be interpolated to form image names in the form of `${REGISTRY}/${PROJECT}/image-name`

The default values are meant to simplify installation on [GKE](https://cloud.google.com/container-engine/).

0. Prerequisites:
-----------------

* Wunderstage expects to deploy into a [Kubernetes](http://kubernetes.io/) cluster with [Deis Workflow](https://deis.com/docs/workflow/quickstart/) installed.
* Wunderstage uses [helm](https://github.com/kubernetes/helm/blob/master/docs/quickstart.md).
* Wunderstage needs access to a docker build host for bootstrapping.

If you don't currently have a Kubernetes cluster with Deis installed you can follow [GKE Quickstart](INSTALL_GCP.md).


1. Setup
--------

 1. Clone `github.com/tmc/wunderstage` to an environment that has push access to your registry. hint: run within a `Google Cloud Shell` for maximum ease.
 2. Build and release images: `$ make release-images`
