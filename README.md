# Grapes

Disposable Kubernetes Cluster Factory

## Why?

As a Kubernetes Engineer I sometimes just need a Kubernetes environment that I can tinker with. Grapes holds the base for this as it provides configuration / automation  

## Guidelines (for me)

- Add as many install methods as you like, just create a new folder and add two workflow files (one for creation, one for deletion)
  - the customization of each cluster should be limited to 10 inputs parameters (limit of github actions)
  - use exact versions (and rely on renovate to update them)
  - only one cluster per method at a time must be possible (more is optional)
- Tech Requirements:
  - The workflow should create a small cluster
  - the API must be public accessible 
  - the Service CIDR range must be `10.127.0.0/16`
  - the Pod CIDR range must be `10.123.0.0/16`
  - Install a CNI 
  - Install a CCM if necessary (some distributions already have this included)
    - should provide block-storage
    - should provide service `type:LoadBalancer` implementation
    - optionally deploy them yourself
  - Leave the rest open to the user
- Credentials should be retrieved from Akeyless via Github Actions
- The worklflow should pill out all required artifacts to connect to the cluster/nodes as well as any required artifacts to further tweak the cluster locally (e.g config or terraform files)
- Code snippets how to solve certain use-cases should be put in the `useful_stuff` folder so that one could use them after the cluster is created

## Installation Methods

### Hetzner-k3s

This method installs k3s on Hcloud using a cool shell script, which you can find over [here](https://github.com/vitobotta/hetzner-k3s). It's quite opiniated but works really well and gives you a basic cluster ready to go.

### EKS-terraform

This method uses the official [terraform-aws-eks](https://github.com/terraform-aws-modules/terraform-aws-eks) module to deploy an EKS cluster using a minimal config.

This method has some sane defaults for cluster installation:
- everything is encrypted using custom KMS keys
- everything is fully HA (except the NAT gateways)
- we reuse the SG created by EKS for all worker nodes (and disable all other SGs)
- we store logs for 30 days in cloudwatch 
- we use `x86_64` nodes (could easily be changed to `amd64`)
- to access/delete/manage the cluster you either need to be the user who created the cluster or have the role `EKSClusterAdmin` assumed 
- AWS SSM is enabled for the nodes

And some prerequisites are also required:
- (if possible) a dedicated AWS accoun
- IAM user with admin privileges
- state bucket in a region (created manually)


## Known-issues

- Hetzner-k3s: cilium installation doesn't quite work as expected (kube-proxy replacement can't be controlled)
- EKS-terraform: login creds are just terraform outputs

## Ideas

- Move [banana-bread](https://github.com/alleaffengaffen/banana-bread) in here as method
- Add method using kops
- Add method using Terraform/Kubespray combo
- Add some generic apps that are deployed to clusters of all methods using GitOps
- Migrate the install methods to cluster-api providers that will bootstrap new clusters
- Find a way to automatically run deletion workflows
