# AWS Load Balancer Controller

In Terraform add: 

```hcl
resource "helm_release" "aws_load_balancer_controller" {
  name             = "aws-load-balancer-controller"
  repository       = "https://aws.github.io/eks-charts"
  chart            = "aws-load-balancer-controller"
  version          = "1.5.3"
  namespace        = "aws"
  create_namespace = true

  values = [
    templatefile("${path.module}/helm_values/aws_load_balancer_controller.yaml", {
      region       = var.region
      cluster_name = var.name
      role_arn     = module.aws_load_balancer_controller_irsa.iam_role_arn
      vpcID        = module.vpc.vpc_id
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
replicaCount: 1
clusterName: ${cluster_name}
ingressClass: alb
region: ${region}
vpcId: ${vpcID}
defaultSSLPolicy: "ELBSecurityPolicy-FS-1-2-Res-2020-10"
tolerations:
  - operator: Equal
    key: "beta.kubernetes.io/arch"
    value: "arm64"
    effect: "NoExecute"

hostNetwork: true # required due to cilium overlay
dnsPolicy: "ClusterFirstWithHostNet"

serviceAccount:
  annotations:
    eks.amazonaws.com/role-arn: ${role_arn}

securityContext:
  capabilities:
    drop:
      - ALL
  readOnlyRootFilesystem: true
  runAsNonRoot: true
  allowPrivilegeEscalation: false

resources:
  limits:
    cpu: 100m
    memory: 256Mi
  requests:
    cpu: 100m
    memory: 128Mi
```
