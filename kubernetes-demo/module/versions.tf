terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.37.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.38.0"
    }
    bcrypt = {
      source  = "viktorradnai/bcrypt"
      version = "0.1.2"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.8.1"
    }
    argocd = {
      source  = "argoproj-labs/argocd"
      version = "7.15.1"
    }
  }
}