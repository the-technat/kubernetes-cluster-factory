# AWS Load Balancer Controller

In Terraform add: 

```hcl
resource "helm_release" "aws_load_balancer_controller" {
  name             = "aws-load-balancer-controller"
  repository       = "https://aws.github.io/eks-charts"
  chart            = "aws-load-balancer-controller"
  version          = "1.6.2"
  namespace        = "aws"
  create_namespace = true

  values = [
    templatefile("${path.module}/helm_values/aws_load_balancer_controller.yaml", {
      region       = var.region
      cluster_name = var.name
      role_arn     = module.aws_load_balancer_controller_irsa.iam_role_arn
      vpcID        = module.vpc.vpc_id
      sa_name = "aws-load-balancer-controller"
    })
  ]

  depends_on = [
    argocd_application.cluster_autoscaler,
    module.aws_load_balancer_controller_irsa
  ]
}

module "aws_load_balancer_controller_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name_prefix                       = "aws-load-balancer-controller"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["aws:aws-load-balancer-controller"]
    }
  }

  tags = local.tags
}
```

And as helm values:

```yaml
clusterName: ${cluster_name}
region: ${region}
vpcId: ${vpcID}

serviceAccount:
  name: ${sa_name}
  annotations:
    eks.amazonaws.com/role-arn: ${role_arn}
```
