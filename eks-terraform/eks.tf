module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.21.0"

  cluster_name    = var.name
  cluster_version = var.eks_version

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent    = true
      before_compute = true
    }
  }

  # Networking
  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_service_ipv4_cidr      = "10.127.0.0/16"
  cluster_endpoint_public_access = true

  # IAM
  kms_key_owners = [data.aws_caller_identity.current.arn,"arn:aws:iam::${data.aws_caller_identity.current.account_id}:root", "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/nuker"] # required for automatic nuking
  manage_aws_auth_configmap =  true
  aws_auth_users = [
    {
      userarn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${var.name}"
      username = var.name
      groups = ["system:masters"]
    },
  ]

  // settings in this block apply to all nodes groups
  eks_managed_node_group_defaults = {
    # Compute
    capacity_type  = "SPOT"
    ami_type       = "AL2_x86_64"
    instance_types = ["t3a.medium", "t3.medium", "t2.medium"]
    ami_id         = data.aws_ami.eks_default.image_id
    desired_size   = var.worker_count

    # IAM
    iam_role_additional_policies = {
      AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    }

    // required since we specify the AMI to use
    // otherwise the nodes don't join
    // setting also assume the default eks image is used
    enable_bootstrap_user_data = true

  }

  eks_managed_node_groups = {
    workers-a = {
      name       = "${var.name}-a"
      subnet_ids = [module.vpc.private_subnets[0]]
    }
    workers-b = {
      name       = "${var.name}-b"
      subnet_ids = [module.vpc.private_subnets[1]]
    }
    workers-c = {
      name       = "${var.name}-c"
      subnet_ids = [module.vpc.private_subnets[2]]
    }
  }

  tags = local.tags
}
