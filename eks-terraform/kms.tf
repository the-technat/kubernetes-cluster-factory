module "cloudwatch_kms_key" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 1.5"

  description             = "Customer managed key to encrypt EKS Cloudwatch Logs"
  deletion_window_in_days = 7

  # Policy
  key_owners = [aws_iam_role.cluster_admin.arn, data.aws_caller_identity.current.arn]
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

  # Aliases
  aliases = ["eks/${var.name}/cloudwatch"]

  tags = local.tags
}

module "ebs_kms_key" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 1.5"

  description             = "Customer managed key to encrypt EKS managed node group volumes"
  deletion_window_in_days = 7

  # Policy
  key_owners = [aws_iam_role.cluster_admin.arn, data.aws_caller_identity.current.arn]
  key_service_roles_for_autoscaling = [
    # required for the ASG to manage encrypted volumes for nodes
    # note that https://docs.aws.amazon.com/autoscaling/ec2/userguide/autoscaling-service-linked-role.html
    # if you get errors about a malformed policy the first time using this
    "arn:aws:iam::${local.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling",
    # required for the cluster / persistentvolume-controller to create encrypted PVCs
    module.eks.cluster_iam_role_arn,
  ]

  # Aliases
  aliases = ["eks/${var.cluster_name}/ebs"]

  tags = local.tags
}
