# digitalocean_doks_demo

 [![pipeline status](https://code.immerda.ch/technat/digitalocean_doks_demo/badges/master/pipeline.svg)](https://code.immerda.ch/technat/digitalocean_doks_demo/-/commits/master)

Setup a DigitalOcean Kubernetes Cluster with some addons and demo apps in a fully automated fashion.

## Overview

[DOKS](https://docs.digitalocean.com/products/kubernetes/) (DigitalOcean Kubernetes Service) is an easy way to spin up kubernetes in the cloud. It creates a basic cluster with [cilium](https://cilium.io/) as cni-plugin, controllers for load-balancers and volumes in DigitalOceans Cloud and comes with autoscaling preenabled.

The cluster is created using [Terraform](https://www.terraform.io/) and the [terraform-digitalocean-doks](https://github.com/nlamirault/terraform-digitalocean-doks) module. To deploy apps onto the cluster we instal some infrastructure tools using [Ansible](https://www.ansible.com/). Mainly the following helm charts:

- [external-dns](https://artifacthub.io/packages/helm/external-dns/external-dns) -> integrated with Hetzner DNS to managed DNS for your ingresses and services
- [cert-manager](https://artifacthub.io/packages/helm/cert-manager/cert-manager) -> ready to issue certificates from Let's Encrypt Staging and Production CA
- [ingress-nginx](https://artifacthub.io/packages/helm/ingress-nginx/ingress-nginx) -> ready to route traffic to your backends
- [argo-cd](https://artifacthub.io/packages/helm/argo/argo-cd) -> setup to lock for ArgoCD apps in the [apps](./apps) folder. 
- [kube-prometheus-stack](https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack)  -> ready to monitor your app using CRDs

To automatically run the tools Gitlab's [CI/CD](https://docs.gitlab.com/ee/ci/) and [terraform-state](https://docs.gitlab.com/ee/user/infrastructure/iac/terraform_state.html) is used. Thus resulting in a single "pipeline" that runs on every change you do and forms the worlds as you desire.

## Usage

Currently the repo is not very well designed to be reused, you have to fork it. Then make sure you have a [gitlab-runner](https://docs.gitlab.com/runner/) registered and the following CI/CD variables set: 

- `do_token`: Masked variable containing an API token for DigitalOcean Cloud

Then you can edit the variables in [tools/tools.yml](./tools/tools.yml) to adjust the config of the infrastructure tools.

It's recommended that you store secrets in an ansible-vault file:

```bash
ansible-vault create secrets.yml
```

The command will prompt you for a Vault password and then open an editor where you can enter the secure variables. Once you save, the command will save that file in your directory but in an encrypted way. If you do that, don't forget to add the vault password as CD/CD variable of type file and the name `ansible_vault_password`.

Once you commit your changes the pipeline should automatically trigger and build your environment.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_digitalocean"></a> [digitalocean](#requirement\_digitalocean) | ~> 2.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_kubernetes"></a> [kubernetes](#module\_kubernetes) | git::https://github.com/the-technat/terraform-digitalocean-doks.git | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_do_token"></a> [do\_token](#input\_do\_token) | API Token to access digitalocean cloud | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
