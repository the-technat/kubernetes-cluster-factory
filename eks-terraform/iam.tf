resource "aws_iam_role_policy_attachment" "account_admin" {
  role       = aws_iam_role.cluster_admin.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"

  depends_on = [aws_iam_user.eks_admin] 
}

resource "aws_iam_role" "cluster_admin" {
  name               = "EKSClusterAdmin"
  assume_role_policy = data.aws_iam_policy_document.cluster_admin_assume.json
}

data "aws_iam_policy_document" "cluster_admin_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
			type        = "AWS"
			identifiers = [aws_iam_user.eks_admin.arn]
    }
  }
  depends_on = [aws_iam_user.eks_admin] 
}

resource "aws_iam_user" "eks_admin" {
  name = "eks_admin_${var.name}"

  tags = local.tags
}

resource "aws_iam_access_key" "eks_admin" {
  user = aws_iam_user.eks_admin.name
}

