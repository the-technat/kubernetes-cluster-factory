output "account_id" {
  value = data.aws_caller_identity.current.account_id
}
output "intructions" {
  value = <<EOT
   Grab the config from the folder in the s3 bucket
 EOT
}
