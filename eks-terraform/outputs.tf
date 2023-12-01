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
   As soon as you can assume the ${var.name}-admin role, you are all good
   This could be an IAM user or an EC2-instance
 EOT
}
