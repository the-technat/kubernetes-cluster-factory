output "name" {
  value = var.name
}
output "region" {
  value = var.region
}
output "iam_user" {
  value = aws_iam_user.eks_admin.name
}
output "iam_user_password" {
  value = aws_iam_user_login_profile.eks_admin.password
}
output "account_id" {
  value = data.aws_caller_identity.current.account_id
}
output "aws_accces_key_id" {
  value = aws_iam_access_key.eks_admin.id
}
output "aws_accces_secret_key" {
  value = nonsensitive(aws_iam_access_key.eks_admin.secret)
}




