# Grapes

Disposable Kubernetes Cluster Factory

## Why?

As a Kubernetes Engineer I sometimes just need a Kubernetes environment that I can tinker with. [banana-bread](https://github.com/alleaffengaffen/banana-bread) is already such a disposable EKS cluster that was used heavily in the last couple of months. But grapes is different in that it supports multiple distributions, not only EKS.

## Guidelines (for me)

- Add as many install methods as you like, just create a new folder and add two workflow files (one for creation, one for deletion)
  - the customization of each cluster should be limited to 10 inputs parameters (limit of github actions)
  - use exact versions (and rely on dependabot or so to update them)
- Requirements:
  - The workflow should create a small cluster
  - the API must be public accessable 
  - the Service CIDR range must be `10.127.0.0/16`
  - the Pod CIDR range must be `10.123.0.0/16`
  - Install a CNI (or offer multiple options)
  - Install a CSI-driver for block-storage
  - Install a CCM if necessary (some services already have this included)
    - this includes the ability to provision L4 loadbalancers
  - Leave the rest unopiniated
- Credentials should be retrieved from Akeyless via Github Actions
- The worklflow should pill out all required artifacts to connect to the cluster/nodes as well as any required articats to further tweak the cluster locally
- Code snippets how to solve certain use-cases should be put in the `useful_stuff` folder so that one could reused them

## Installation Methods

### Hetzner-k3s

This method installs k3s on Hcloud using a cool shell script, which you can find over [here](https://github.com/vitobotta/hetzner-k3s). It's quite opiniated but works really well and gives you a basic cluster ready to go.

### EKS-terraform

This method uses the official [terraform-aws-eks](https://github.com/terraform-aws-modules/terraform-aws-eks) module to deploy an EKS cluster using a minimal config.

This method has some sane defaults for cluster installation:
- everything is encrypted using custom KMS keys
- we reuse the SG created by EKS for all worker nodes (and disable all other SGs)
- we store logs for 30 days in cloudwatch 
- we use `x86_64` nodes (could easily be changed to `amd64`)
- to access/delete/manage the cluster you either need to be the user who created the cluster or have the role `EKSClusterAdmin` assumed 
- AWS SSM is enabled for the nodes

## Known-issues

- Hetzner-k3s: Currently only one cluster at a time can be deployed because I was too lazy finding a shell command that would spill out a free IP range that's not used for a Hcloud Network already.
- Hetzner-k3s: cilium installation doesn't quite work as expected (kube-proxy replacement can't be controlled)

## Ideas

- Move [banana-bread](https://github.com/alleaffengaffen/banana-bread) in here as method
- Add method using kops
- Add method using Terraform/Kubespray combo
- Add some generic apps that are deployed to clusters of all methods using GitOps
- Migrate the install methods to cluster-api providers that will bootstrap new clusters
- Find a way to automatically run deletion workflows
