#####################
# Variables
#####################
variable "region" {
  type        = string
  description = "AWS region to use"
  default     = "eu-west-1"
}
variable "resource_name" {
  type        = string
  description = "How things are named"
}
variable "vpc_cidr" {
  type        = string
  description = "CIDR for the AWS VPC"
  default     = "10.123.0.0/16"
}
variable "service_cidr" {
  type        = string
  description = "K8s service CIDR"
  default     = "10.127.0.0./16"
}
variable "eks_version" {
  type        = string
  description = "EKS version to use (only up to minor part)"
  default     = "1.28"
}
variable "tags" {
  type        = map[string]
  description = "Tags to apply to all resources"
  default = {
    cluster    = var.resource_name
    repo       = "github.com/the-technat/grapes"
    managed-by = "terraform"
  }
}
variable "single_nat_gateway" {
  type        = string
  description = "To save cost a single-AZ NAT gateway can be deployed"
  default     = true
}
variable "instance_types" {
  type        = list(string)
  description = "Instance types to use (must be x86_64 ARCH)"
  default     = ["t3a.medium", "t3.medium", "t2.medium"]
}
variable "worker_count" {
  type        = number
  description = "The number of worker-nodes to deploy initially (3x since we have 3AZs)"
}

#####################
# Requirements / Versions
#####################
terraform {
  backend "s3" {} # github actions will configure the rest
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.54.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.29.0"
    }
  }
}

#####################
# Providers
#####################
provider "aws" {
  region = var.region
}
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--output", "json"] # requires the aws-cli to be installed on the machine terraform is executed
  }
}
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--output", "json"] # requires the aws-cli to be installed on the machine terraform is executed
    }
  }
}

#####################
# data sources
#####################
data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}
data "aws_ami" "eks_default_x86_64" { # use eks-community-ami
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.eks_version}-v*"]
  }
}

#####################
# VPC
#####################
module "vpc" {
  source             = "terraform-aws-modules/vpc/aws"
  version            = "5.8.1"
  name               = var.resource_name
  cidr               = var.vpc_cidr
  azs                = slice(data.aws_availability_zones.available.names, 0, 3)
  public_subnets     = [for k, v in slice(data.aws_availability_zones.available.names, 0, 3) : cidrsubnet(var.vpc_cidr, 8, k)]
  private_subnets    = [for k, v in slice(data.aws_availability_zones.available.names, 0, 3) : cidrsubnet(var.vpc_cidr, 8, k + 10)]
  enable_nat_gateway = true                   # deploy NAT gateways into the public subnets
  single_nat_gateway = var.single_nat_gateway # either in all public subnets or only the first one
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1 # required for the ALBC
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1 # required for the ALBC
  }
  tags = var.tags
}

#####################
# EKS
#####################
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.14.0"
  cluster_name    = var.resource_name
  cluster_version = var.eks_version
  cluster_addons = {
    coredns    = { most_recent = true }
    kube-proxy = { most_recent = true }
    vpc-cni = {
      most_recent    = true
      before_compute = true
    }
  }
  vpc_id                                   = module.vpc.vpc_id
  subnet_ids                               = module.vpc.private_subnets
  cluster_service_ipv4_cidr                = var.service_cidr
  cluster_endpoint_public_access           = true
  attach_cluster_encryption_policy         = false # KMS only causes problems when destroyed regurarly
  create_kms_key                           = false # KMS only causes problems when destroyed regurarly
  cluster_encryption_config                = {}    # KMS only causes problems when destroyed regurarly
  enable_cluster_creator_admin_permissions = true  # the creator of the cluster shall be an admin
  access_entries                           = {}
  eks_managed_node_group_defaults = {
    capacity_type  = "SPOT"
    ami_type       = "AL2_x86_64"
    ami_id         = data.aws_ami.eks_default_x86_64.image_id
    instance_types = var.instance_types
    desired_size   = var.worker_count
    iam_role_additional_policies = {
      AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    }
    enable_bootstrap_user_data = true # required if ami_id is specified and the community EKS AMI is used
  }
  eks_managed_node_groups = {
    workers-a = {
      name       = "${var.resource_name}-a"
      subnet_ids = [module.vpc.private_subnets[0]]
    }
    workers-b = {
      name       = "${var.resource_name}-b"
      subnet_ids = [module.vpc.private_subnets[1]]
    }
    workers-c = {
      name       = "${var.resource_name}-c"
      subnet_ids = [module.vpc.private_subnets[2]]
    }
  }
  tags = var.tags
}
