#----------------
# Environment Vars
#----------------
variable "do_token" {
  type        = string
  sensitive   = true
  description = "API Token to access digitalocean cloud"
}
