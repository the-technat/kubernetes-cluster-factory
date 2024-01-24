# Podinfo


```
resource "helm_release" "podinfo" {
  name             = "podinfo"
  repository       = "https://stefanprodan.github.io/podinfo"
  chart            = "podinfo"
  version          = "6.5.4"
  namespace        = "podinfo"
  create_namespace = true
  wait             = true
  timeout          = 3600

  values = [
    templatefile("${path.module}/helm_values/podinfo.yaml", {})
  ]

  depends_on = [
    helm_release.contour,
  ]
}
```


```yaml
replicaCount: 3
logLevel: info
host: #0.0.0.0
backend: #http://backend-podinfo:9898/echo
backends: []

ui:
  color: "#9A9B73"
  message: "Technat's Cilium Testing"
  logo: ""

# failure conditions
faults:
  delay: false
  error: false
  unhealthy: false
  unready: false
  testFail: false
  testTimeout: false

service:
  type: ClusterIP
    
ingress:
  enabled: true
  className: "alb"
  annotations: 
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS":443}]'
    alb.ingress.kubernetes.io/ssl-redirect: '443'
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/healthcheck-protocol: HTTP
    alb.ingress.kubernetes.io/healthcheck-port: "9898"
    alb.ingress.kubernetes.io/healthcheck-path: /readyz
  hosts:
    - host: podinfo.technat.dev
      paths:
        - path: /
          pathType: Prefix
  tls:
  - hosts:
      - podinfo.technat.dev
```