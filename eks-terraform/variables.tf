variable "name" {
  type = string
}

variable "region" {
  type = string
}

variable "ha" {
  type = bool
}

variable "cidr" {
  type = string
}

variable "eks_version" {
  type = string
}

variable "worker_count" {
  type = number
}
