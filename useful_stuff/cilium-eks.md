# Cilium on EKS

Using Cilium in ENI mode on EKS

You need two parts:

```cilium.tf
###############
# Cilium
##############
resource "helm_release" "cilium" {
  name       = "cilium"
  repository = "https://helm.cilium.io"
  chart      = "cilium"
  version    = "1.15.0"
  namespace  = "kube-system"
  wait       = true
  timeout    = 3600

  values = [
    templatefile("${path.module}/helm_values/cilium.yaml", {
      cluster_endpoint = trim(module.eks.cluster_endpoint, "https://") # would be used for kube-proxy replacement
      cluster_name = var.resource_name
    })
  ]

  depends_on = [
    module.eks.aws_eks_cluster,
    null_resource.purge_aws_networking,
  ]
}

resource "null_resource" "purge_aws_networking" {
  triggers = {
    eks = module.eks.cluster_endpoint # only do this when the cluster changes (e.g create/recreate)
  }

  provisioner "local-exec" {
    command = <<EOT
      aws eks --region ${local.region} update-kubeconfig --name ${var.name}
      curl -LO https://dl.k8s.io/release/v${var.eks_version}.0/bin/linux/amd64/kubectl
      chmod 0755 ./kubectl
      ./kubectl -n kube-system delete daemonset kube-proxy --ignore-not-found 
      ./kubectl -n kube-system delete daemonset aws-node --ignore-not-found
    EOT
  }
}
```

And the corresponding values:

```cilium.yaml
rollOutCiliumPods: true
cluster:
  name: ${cluster_name}
hubble:
  enabled: true
  relay:
    rollOutPods: true
    enabled: true
routingMode: "native"
eni:
  enabled: true
ipam:
  mode: eni
  awsEnablePrefixDelegation: true
kubeProxyReplacement: strict
k8sServicePort: 443
k8sServiceHost: ${cluster_endpoint}
operator:
  rollOutPods: true
  replicas: 1
```
