variable "name" {
  type = string
}

variable "single_nat_gateway" {
  type = bool
}

variable "eks_version" {
  type = string
}

variable "worker_count" {
  type = number
}
