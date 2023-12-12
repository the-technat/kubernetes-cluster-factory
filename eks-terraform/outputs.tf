output "name" {
  value = var.name
}
output "region" {
  value = var.region
}
output "account_id" {
  value = data.aws_caller_identity.current.account_id
}
output "intructions" {
  value = <<EOT
   Rotate the credentials for the user ${var.name} in AWS IAM
   And configure yourself access to the cluster via these credentials
 EOT
}
