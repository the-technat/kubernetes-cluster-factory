terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.68.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.32.0"
    }
    bcrypt = {
      source  = "viktorradnai/bcrypt"
      version = "0.1.2"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }
    argocd = {
      source  = "oboukili/argocd"
      version = "6.2.0"
    }
  }
}