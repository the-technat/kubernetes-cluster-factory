output "aws_accces_key_id" {
	value = aws_iam_access_key.eks_admin.id
}

output "aws_accces_secret_key" {
	value = nonsensitive(aws_iam_access_key.eks_admin.secret)
}
