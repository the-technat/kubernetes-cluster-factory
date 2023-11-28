# locals that hold data from datasources
locals {
  tags = {
    cluster    = var.name
    repo       = "github.com/the-technat/grapes"
    managed-by = "terraform"
  }
  azs = var.ha ? slice(data.aws_availability_zones.available.names, 0, 3) : slice(data.aws_availability_zones.available.names, 0, 1)
}

data "aws_availability_zones" "available" {}

data "aws_caller_identity" "current" {}

# use pre-build images by AWS
data "aws_ami" "eks_default" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.eks_version}-v*"]
  }
}
