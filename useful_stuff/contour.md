# Contour

```hcl
locals {
  contour_name = "contour"
}

resource "helm_release" "contour" {
  name             = local.contour_name
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "contour"
  version          = "15.2.0"
  namespace        = local.contour_name
  create_namespace = true

  values = [
    templatefile("${path.module}/helm_values/contour.yaml", {
      ingress_wildcard_cert = aws_acm_certificate.ingress_wildcard.arn
    })
  ]

  depends_on = [
    helm_release.cilium,
    helm_release.aws_load_balancer_controller,
  ]
}
```

And the values file:

```yaml
contour:
  ingressClass:
    name: "contour"
    create: true
    default: true

envoy:
  service:
    externalTrafficPolicy: Local
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-name: contour-envoy
      service.beta.kubernetes.io/aws-load-balancer-scheme: "internet-facing"
      service.beta.kubernetes.io/aws-load-balancer-ip-address-type: ipv4


defaultBackend:
  enabled: true
  image:
    registry: ghcr.io
    repository: the-technat/alleaffengaffen
    tag: main
 
  containerPorts:
    http: 8080
```