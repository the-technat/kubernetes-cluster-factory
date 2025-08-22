module "eks_full" {
  source = "./module"

  cluster_name      = "demo"
  region            = "eu-west-1"       # also change in provider definition below
  dns_zone          = "aws.technat.dev" # also change in the NS records below
  account_id        = "351425708426"    # also change in aws_auth_users list below
  onboarding_repo   = "https://github.com/the-technat/kubernetes-demo.git"
  onboarding_folder = "apps"
  email             = "technat+aws@technat.ch"

  access_entries = {
    technat = {
      principal_arn = "arn:aws:iam::351425708426:user/technat"
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }
  tags = {}
}

provider "aws" {
  region = "eu-west-1"
}

################
# Outputs
################
output "grafana_password" {
  value = nonsensitive(module.eks_full.grafana_password)
}

output "argocd_password" {
  value = nonsensitive(module.eks_full.argocd_password)
}

output "dns_ns_records" {
  value = module.eks_full.ns_records 
}