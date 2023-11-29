output "name" {
  value = var.name
}
output "region" {
  value = var.region
}
output "aws_iam_user" {
  value = aws_iam_user.eks_admin.name
}
output "aws_accces_key_id" {
  value = aws_iam_access_key.eks_admin.id
}
output "aws_accces_secret_key" {
  value = nonsensitive(aws_iam_access_key.eks_admin.secret)
}




