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
   As soon as you assumed the ${var.name}-admin role, you are ready to tinker.
   Use the specificed principal to access the cluster.
 EOT
}
