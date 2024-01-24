# Cilium on EKS

You need two parts:

```cilium.tf
###############
# Cilium
##############
resource "helm_release" "cilium" {
  name       = "cilium"
  repository = "https://helm.cilium.io"
  chart      = "cilium"
  version    = "1.14.6"
  namespace  = "kube-system"
  wait       = true
  timeout    = 3600

  values = [
    templatefile("${path.module}/helm_values/cilium.yaml", {
      cluster_endpoint = trim(module.eks.cluster_endpoint, "https://") # would be used for kube-proxy replacement
    })
  ]

  depends_on = [
    module.eks.aws_eks_cluster,
    null_resource.purge_aws_networking,
  ]
}

resource "null_resource" "purge_kube_proxy" {
  triggers = {
    eks = module.eks.cluster_endpoint # only do this when the cluster changes (e.g create/recreate)
  }

  provisioner "local-exec" {
    command = <<EOT
      aws eks --region ${local.region} update-kubeconfig --name ${var.name}
      curl -LO https://dl.k8s.io/release/v1.27.0/bin/linux/amd64/kubectl
      chmod 0755 ./kubectl
      ./kubectl -n kube-system delete daemonset kube-proxy --ignore-not-found 
    EOT
  }
}


resource "null_resource" "purge_aws_networking" {
  triggers = {
    eks = module.eks.cluster_endpoint # only do this when the cluster changes (e.g create/recreate)
  }

  provisioner "local-exec" {
    command = <<EOT
      aws eks --region ${local.region} update-kubeconfig --name ${var.name}
      curl -LO https://dl.k8s.io/release/v1.27.0/bin/linux/amd64/kubectl
      chmod 0755 ./kubectl
      ./kubectl -n kube-system delete daemonset aws-node --ignore-not-found
    EOT
  }
}
```

And the corresponding values:

```cilium.yaml
## cni-chaining values
# https://docs.cilium.io/en/stable/installation/cni-chaining-aws-cni/
# cni:
#   chainingMode: aws-cni
#   exclusive: false
# enableIPv4Masquerade: false
# tunnel: disabled
# endpointRoutes:
#   enabled: true
# remoteNodeIdentity: false
# bpf:
#   # explicitly set hostLegacy routing, required since EKS 1.24
#   # somewhat related https://github.com/cilium/cilium/issues/20677
#   hostLegacyRouting: true

## ENI Integration values
# https://docs.cilium.io/en/v1.13/installation/k8s-install-helm/#install-cilium -> eks
eni:
  enabled: true
ipam:
  mode: eni
egressMasqueradeInterfaces: eth0
tunnel: disabled
bpf:
  hostLegacyRouting: true # somehow on EKS this is required, but you could check whether it's still required

# kube-proxy replacement
# also requires ./kubectl -n kube-system delete daemonset kube-proxy --ignore-not-found in purge_aws_networking
# cilium ingress gateway requires either partial or strict for the replacement
kubeProxyReplacement: strict
k8sServiceHost: ${cluster_endpoint}
k8sServicePort: "443"

## General values
rollOutCiliumPods: true
priorityClassName: "system-node-critical"
annotateK8sNode: true
policyEnforcementMode: "always"
policyAuditMode: true

operator:
  replicas: 1 # otherwise the other replica won't scale up
  rollOutPods: true
hubble:
  enabled: true
  rollOutPods: true
  relay:
    enabled: true
    rollOutPods: true
  ui:
    enabled: true
    rollOutPods: true
```
