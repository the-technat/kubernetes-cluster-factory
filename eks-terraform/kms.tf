module "eks_kms_key" {
  source  = "terraform-aws-modules/kms/aws"
  version = "2.1.0"

  aliases                 = ["eks/${var.name}"]
  description             = "Customer managed key to encrypt EKS managed control-plane resources"
  deletion_window_in_days = 7
  key_owners              = [aws_iam_role.cluster_admin.arn, data.aws_caller_identity.current.arn]
  enable_default_policy   = true

  tags = local.tags
}

module "ebs_kms_key" {
  source  = "terraform-aws-modules/kms/aws"
  version = "2.1.0"

  aliases                 = ["eks/${var.name}/ebs"]
  description             = "Customer managed key to encrypt EKS managed node group volumes"
  deletion_window_in_days = 7
  key_owners              = [aws_iam_role.cluster_admin.arn, data.aws_caller_identity.current.arn]
  key_service_roles_for_autoscaling = [
    # required for the ASG to manage encrypted volumes for nodes
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling",
    # required for the cluster / persistentvolume-controller to create encrypted PVCs
    module.eks.cluster_iam_role_arn,
  ]

  tags = local.tags
}

module "cloudwatch_kms_key" {
  source  = "terraform-aws-modules/kms/aws"
  version = "2.1.0"

  aliases                 = ["eks/${var.name}/cloudwatch"]
  description             = "Customer managed key to encrypt EKS Cloudwatch Logs"
  deletion_window_in_days = 7
  key_owners              = [aws_iam_role.cluster_admin.arn, data.aws_caller_identity.current.arn]
  key_statements = [
    {
      sid = "CloudWatchLogs"
      actions = [
        "kms:Encrypt*",
        "kms:Decrypt*",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:Describe*"
      ]
      resources = ["*"]

      principals = [
        {
          type        = "Service"
          identifiers = ["logs.${var.region}.amazonaws.com"]
        }
      ]

      conditions = [
        {
          test     = "ArnLike"
          variable = "kms:EncryptionContext:aws:logs:arn"
          values = [
            "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:*",
          ]
        }
      ]
    }
  ]

  tags = local.tags
}

