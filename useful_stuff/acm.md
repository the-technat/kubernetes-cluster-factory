# ACM

Need a quick cert to test?

```
provider "hetznerdns" {
    apitoken = "HCLOUD_DNS_TOKEN"
}

terraform {
  required_providers {
    hetznerdns = {
      source = "timohirt/hetznerdns"
    }
  } 
}

data "hetznerdns_zone" "technat_dev" {
  name = "technat.dev"
}

resource "aws_acm_certificate" "ingress_wildcard" {
  domain_name       = "*.technat.dev"
  validation_method = "DNS"

  tags = local.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "hetznerdns_record" "ingress_wildcard_verify" {
  for_each = {
    for dvo in aws_acm_certificate.ingress_wildcard.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = data.hetznerdns_zone.technat_dev.id
  name    = each.value.name
  value   = each.value.record
  type    = each.value.type
  ttl     = 60
}

resource "aws_acm_certificate_validation" "ingress_wildcard" {
  certificate_arn = aws_acm_certificate.ingress_wildcard.arn
}

# read the LB created by your ingress controller
data "aws_lb" "contour" {
  name = local.contour_name

  depends_on = [helm_release.contour, ]
}

resource "hetznerdns_record" "wildcard" {
  zone_id = data.hetznerdns_zone.technat_dev.id
  name    = "*"
  value   = "${data.aws_lb.contour.dns_name}."
  type    = "CNAME"
  ttl     = 60

  depends_on = [data.aws_lb.contour]
}
```