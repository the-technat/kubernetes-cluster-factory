# Grapes

Disposable Kubernetes Cluster Factory

## Why?

As a Kubernetes Engineer I sometimes just need a Kubernetes environment that I can tinker with. Grapes holds the base for this as it provides configuration / automation  

## Guidelines (for me)

- Add as many install methods as you like, just create a new folder and add two workflow files (one for creation, one for deletion)
  - the customization of each cluster should be limited to 10 inputs parameters (limit of github actions), so keep yourself to the minimal as well
  - use exact versions (and rely on renovate to update them)
  - only one cluster per method at a time must be possible (more is optional)
  - the workflow will be triggered manually
- Tech Requirements:
  - The workflow should create a small cluster 
  - The worfklow should create a non-HA cluster (where possible)
  - the API must be public accessible 
  - the Service CIDR range must be `10.127.0.0/16`
  - the Pod CIDR range must be `10.123.0.0/16`
  - Install a CNI 
  - Install a CCM if necessary (some distributions already have this included)
    - should provide block-storage
    - should provide service `type:LoadBalancer` implementation
  - Leave the rest open to the user
- Credentials should be retrieved from Akeyless via Github Actions
- The workflow should print out a text saying where you can access the cluster
  - But there should be no sensitive output nor in artifacts or logs
- Code snippets how to solve special use-cases should be put in the `useful_stuff` folder so that one could use them after the cluster is created
  Or simply create a blog post about a topic ;)

## Installation Methods

### Hetzner-k3s

This method installs k3s on Hcloud using a cool shell script, which you can find over [here](https://github.com/vitobotta/hetzner-k3s). It's quite opiniated but works really well and gives you a basic cluster ready to go.

To get started all that was needed is:
- a Hetzner Project
- an Account API Token 

Some outputs to access the cluster are stored on S3, so grab them after the cluster has been created.

### EKS-terraform

This method uses the official [terraform-aws-eks](https://github.com/terraform-aws-modules/terraform-aws-eks) module to deploy an EKS cluster.

This method has some highlights:
- everything is fully HA (optionally also the NAT gateways)
- we use `x86_64` nodes (could easily be changed to `amd64`)
- AWS SSM is enabled for the nodes

### State

All methos are allowed to save state on S3. 

The following infrastructure was setup for that:
- an OIDC provider for Github Actions
- an IAM role with a trust-policy so that this repository can assume it
- an IAM policy for the role
- an S3 bucket for state
- [account-nuker](https://github.com/the-technat/account-nuker) that regurarly nukes left-over resources


