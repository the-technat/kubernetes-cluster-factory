# terraform-aws-eks-full

An opiniated Terraform monolith that deploys an EKS cluster including it's network and add-ons on the cluster for a full Kubernetes experience.

## Usage

Please don't use this module! It's highly opiniated and not meant for others to use (at least not now).

## Technical Debts

Currently most of the stuff the module deploys works, however:
- Many things can't be controlled from the outside (like feature toggles or config overrides)
- No app is HA (to be discussed if needed or added as feature toggle)
- No app is secure (missing securityContexts, except apps that are secure by default)
- No app has resource requests/limits (expect apps that have defaults)
- No app has network policies 
- No app has authentication (and those who have, just have a local admin user only suitable for Terraform)

## Design Decisions

- Everything is deployed using Terraform 
- Infrastructure addons are deploying using the helm provider
- Dependencies shall be strict and clear, providing seamless deploy and destroy runs 
- Metrics are enabled for almost all components and scraped using service-based discovery 

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| argocd | 6.1.1 |
| aws | 5.54.1 |
| bcrypt | 0.1.2 |
| kubernetes | 2.31.0 |
| random | 3.6.2 |

## Providers

| Name | Version |
|------|---------|
| argocd | 6.1.1 |
| aws | 5.54.1 |
| bcrypt | 0.1.2 |
| helm | n/a |
| kubernetes | 2.31.0 |
| null | n/a |
| random | 3.6.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| aws\_cluster\_autoscaler\_irsa | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | 5.39.1 |
| aws\_ebs\_csi\_driver\_irsa | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | 5.39.1 |
| aws\_external\_dns\_irsa | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | 5.39.1 |
| aws\_load\_balancer\_controller\_irsa | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | 5.39.1 |
| cert\_manager\_dns\_01\_irsa | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | 5.39.1 |
| eks | terraform-aws-modules/eks/aws | 20.11.0 |
| grafana\_irsa | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | 5.39.1 |
| vpc | terraform-aws-modules/vpc/aws | 5.8.1 |

## Resources

| Name | Type |
|------|------|
| [argocd_application.app_of_apps](https://registry.terraform.io/providers/oboukili/argocd/6.1.1/docs/resources/application) | resource |
| [aws_route53_zone.primary](https://registry.terraform.io/providers/hashicorp/aws/5.54.1/docs/resources/route53_zone) | resource |
| [bcrypt_hash.argocd_password](https://registry.terraform.io/providers/viktorradnai/bcrypt/0.1.2/docs/resources/hash) | resource |
| [helm_release.argocd](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.aws_ebs_csi_driver](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.aws_load_balancer_controller](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.cert_manager](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.cert_manager_extras](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.cilium](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.cluster_autoscaler](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.external_dns](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.grafana](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.ingress_nginx](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.ksm](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.metrics_server](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.node_exporter](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.vm](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_ingress_v1.argocd_server](https://registry.terraform.io/providers/hashicorp/kubernetes/2.31.0/docs/resources/ingress_v1) | resource |
| [kubernetes_ingress_v1.hubble_ui](https://registry.terraform.io/providers/hashicorp/kubernetes/2.31.0/docs/resources/ingress_v1) | resource |
| [kubernetes_namespace_v1.albc](https://registry.terraform.io/providers/hashicorp/kubernetes/2.31.0/docs/resources/namespace_v1) | resource |
| [kubernetes_namespace_v1.argocd](https://registry.terraform.io/providers/hashicorp/kubernetes/2.31.0/docs/resources/namespace_v1) | resource |
| [kubernetes_namespace_v1.aws_ebs_csi_driver](https://registry.terraform.io/providers/hashicorp/kubernetes/2.31.0/docs/resources/namespace_v1) | resource |
| [kubernetes_namespace_v1.cert_manager](https://registry.terraform.io/providers/hashicorp/kubernetes/2.31.0/docs/resources/namespace_v1) | resource |
| [kubernetes_namespace_v1.cluster_autoscaler](https://registry.terraform.io/providers/hashicorp/kubernetes/2.31.0/docs/resources/namespace_v1) | resource |
| [kubernetes_namespace_v1.external_dns](https://registry.terraform.io/providers/hashicorp/kubernetes/2.31.0/docs/resources/namespace_v1) | resource |
| [kubernetes_namespace_v1.grafana](https://registry.terraform.io/providers/hashicorp/kubernetes/2.31.0/docs/resources/namespace_v1) | resource |
| [kubernetes_namespace_v1.ingress_nginx](https://registry.terraform.io/providers/hashicorp/kubernetes/2.31.0/docs/resources/namespace_v1) | resource |
| [kubernetes_namespace_v1.ksm](https://registry.terraform.io/providers/hashicorp/kubernetes/2.31.0/docs/resources/namespace_v1) | resource |
| [kubernetes_namespace_v1.metrics_server](https://registry.terraform.io/providers/hashicorp/kubernetes/2.31.0/docs/resources/namespace_v1) | resource |
| [kubernetes_namespace_v1.node_exporter](https://registry.terraform.io/providers/hashicorp/kubernetes/2.31.0/docs/resources/namespace_v1) | resource |
| [kubernetes_namespace_v1.vm](https://registry.terraform.io/providers/hashicorp/kubernetes/2.31.0/docs/resources/namespace_v1) | resource |
| [null_resource.purge_aws_networking](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_password.argocd_password](https://registry.terraform.io/providers/hashicorp/random/3.6.2/docs/resources/password) | resource |
| [random_password.grafana_password](https://registry.terraform.io/providers/hashicorp/random/3.6.2/docs/resources/password) | resource |
| [aws_ami.eks_default](https://registry.terraform.io/providers/hashicorp/aws/5.54.1/docs/data-sources/ami) | data source |
| [aws_ami.eks_default_arm](https://registry.terraform.io/providers/hashicorp/aws/5.54.1/docs/data-sources/ami) | data source |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/5.54.1/docs/data-sources/availability_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access\_entries | Map of access entries to add to the cluster | `any` | `{}` | no |
| account\_id | AWS Account ID | `string` | n/a | yes |
| arch | Do you want a ARM or Intel\|AMD based cluster? | `string` | `"x86_64"` | no |
| capacity\_type | Shall we use SPOT instances or on-demand instances? | `string` | `"SPOT"` | no |
| cluster\_name | Name of the cluster and it's dependend resources | `string` | n/a | yes |
| desired\_count | Starting count of nodes per AZ | `number` | `1` | no |
| dns\_zone | The name of a DNS zone that will be created in Route53 | `string` | n/a | yes |
| eks\_version | Cluster version to use | `string` | `"1.28"` | no |
| email | Mail used for ACME and other things | `string` | n/a | yes |
| instance\_types | A list of instance types to use in the cluster, the order represents the priority | `list(string)` | <pre>[<br>  "t3a.large",<br>  "t3.large",<br>  "t2.large"<br>]</pre> | no |
| max\_count | Max number of nodes per AZ at any time | `number` | `1` | no |
| min\_count | Minimal number of nodes per AZ at any time | `number` | `1` | no |
| onboarding\_branch | Branch to use for onboarding repo | `string` | `"HEAD"` | no |
| onboarding\_folder | Folder where Argo CD App definitions are found | `string` | `"apps"` | no |
| onboarding\_repo | Repository to configure for Argo CD App of Apps pattern | `string` | n/a | yes |
| region | AWS Region you are deploying to | `string` | n/a | yes |
| service\_cidr | Service CIDR used by kube-proxy and it's replacements | `string` | `"10.127.0.0/16"` | no |
| single\_nat\_gateway | For true HA egress-traffic disable this toggle to deploy a NAT gateway per AZ | `bool` | `true` | no |
| tags | Tags to apply to all resources | `map(string)` | <pre>{<br>  "managed-by": "terraform",<br>  "repo": "github.com/the-technat/terraform-aws-eks-full"<br>}</pre> | no |
| vpc\_cidr | CIDR range to use for the VPC/subnets used by the cluster | `string` | `"10.123.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| argocd\_password | Admin Password for Argo CD |
| cluster\_certificate\_authority\_data | CA certificate for EKS control plane endpoint |
| cluster\_endpoint | Endpoint for EKS control plane. |
| cluster\_name | Name of the cluster |
| grafana\_password | Admin Password for Grafana |
| ns\_records | NS records of the created DNS |
<!-- END_TF_DOCS -->