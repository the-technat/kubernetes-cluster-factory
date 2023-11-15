terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
    }
    helm = {
      source  = "hashicorp/helm"
    }
    argocd = {
      source  = "oboukili/argocd"
    }
    bcrypt = {
      source  = "viktorradnai/bcrypt"
    }
  }
}
