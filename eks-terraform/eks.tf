module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.20.0"

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
      configuration_values = jsonencode({
        env = {
          # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
  }

  # Networking
  vpc_id                         = module.vpc.vpc_id
  cluster_service_ipv4_cidr      = "10.127.0.0/16"
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true
  create_cluster_security_group  = false # we just use the eks-managed SG
  create_node_security_group     = false # we just use the eks-managed SG


  # Logging
  cloudwatch_log_group_retention_in_days = 30
  cloudwatch_log_group_kms_key_id        = module.cloudwatch_kms_key.key_arn

  # KMS
  create_kms_key = false
  cluster_encryption_config = {
    resources        = ["secrets"]
    provider_key_arn = module.eks_kms_key.key_arn
  }

  # IAM
  enable_irsa               = true
  manage_aws_auth_configmap = true
  aws_auth_roles = [
    {
      rolearn  = aws_iam_role.cluster_admin.arn
      username = "EKSClusterAdminPolicy"
      groups   = ["system:masters"]
    },
  ]
  aws_auth_users = [
    {
      rolearn  = data.aws_caller_identity.current.arn
      username = data.aws_caller_identity.current.user_id
      groups   = ["system:masters"]
    }
  ]

  // settings in this block apply to all nodes groups
  eks_managed_node_group_defaults = {
    use_name_prefix = true
    metadata_options = {
      http_endpoint               = "enabled"
      http_tokens                 = "required"
      http_put_response_hop_limit = 2
      instance_metadata_tags      = "disabled" # only non-default setting in this block
    }
    update_config = {
      max_unavailable_percentage = 33 # module's default, stable but still fast
    }
    force_update_version = true # after 15min of unsuccessful draining, pods are force-killed

    # Compute
    capacity_type  = "SPOT"
    ami_type       = "AL2_x86_64"
    instance_types = ["t3a.medium", "t3.medium", "t2.medium"]
    ami_id         = data.aws_ami.eks_default.image_id
    desired_size   = var.worker_count

    # Networking
    network_interfaces = [
      {
        delete_on_termination = true
        security_groups       = [module.eks.cluster_primary_security_group_id] # use only eks-managed SG 
      }
    ]

    # Storage
    block_device_mappings = {
      xvda = {
        device_name = "/dev/xvda"
        ebs = {
          volume_size           = 50
          volume_type           = "gp3"
          iops                  = 3000 # default for gp3
          throughput            = 150  # default for gp3
          encrypted             = true
          kms_key_id            = module.ebs_kms_key.key_arn
          delete_on_termination = true
        }
      }
    }

    # IAM
    iam_role_attach_cni_policy = true
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
