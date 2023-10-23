# Grapes

Disposable Kubernetes Cluster Factory

## Why?

As a Kubernetes Engineer I sometimes just need a Kubernetes environment that I can tinker with. [banana-bread](https://github.com/alleaffengaffen/banana-bread) is already such a disposable EKS cluster that was used heavily in the last couple of months. But grapes is different in that it supports multiple distributions, not only EKS.

## Key facts

- Add as many install methods as you like, just create a new folder and add a workflow file
- The automation should create the cluster, install a CNI, CSI-driver and CCM if necessary
- Multiple cloud-providers are possible
- Credentials should be retrieved from Akeyless via Github Actions
- Spill out all required artifacts to connect to the cluster as files in the workflow

## Hetzner-k3s

This method installs k3s on Hcloud using a cool shell script, which you can find over [here](https://github.com/vitobotta/hetzner-k3s). It's quite opiniated but 

### Key facts

- Uses the Hcloud token fetched in the workflow for all services within the cluster

### Known-issues

- Currently only one cluster at a time can be deployed because I was too lazy finding a shell command that would spill out a free IP range that's not used for a Hcloud Network already.

### To Do

- the destroy workflow is not yet finished
- the account-nuker needs to be configured for the grapes project
- cilium installation doesn't quite work as expected
- do a test run with all possible options

## Ideas

- Add method using kops
- Add method using Terraform/Kubespray combo
- Move [banana-bread](https://github.com/alleaffengaffen/banana-bread) in here as method
- Add some generic apps that are deployed to clusters of all methods using GitOps