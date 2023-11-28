# ARM64 nodes on EKS

```
data "aws_ami" "eks_default_arm" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amazon-eks-arm64-node-${var.eks_version}-v*"]
  }
}

eks_managed_node_group_defaults = {
	ami_type       = "AL2_X86_64"
	ami_id         = data.aws_ami.eks_default_arm.image_id
	instance_types = ["t4g.medium", "c6g.large", "c6gd.large", "c6gn.large"]
}
```
