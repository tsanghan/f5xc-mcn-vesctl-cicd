## Global variables
variable "create_ves_namespace" {
  type    = bool
  default = true
}

variable "name" {
  type = string
  # default = "tsanghan"
  default = "tsanghan-brewz"
}

variable "xc_base_domain" {
  type    = string
  default = "dev.learnf5.cloud"
}

variable "http_port" {
  type    = number
  default = 80
}

variable "loadbalancer_algorithm" {
  type    = string
  default = "ROUND ROBIN"
}

variable "aws_region" {
  type    = string
  default = "ap-southeast-1"
}

variable "ssh_pub_key" {
  type = string
}

variable "aws_vpc_cidr" {
  type    = string
  default = "192.168.0.0/20"
}

variable "aws_az" {
  type    = string
  default = "ap-southeast-1a"
}

variable "outside_subnet_cidr_block" {
  type    = string
  default = "192.168.0.0/25"
}

## Health check
variable "health_check" {
  type = object({
    threshold           = number
    interval            = number
    timeout             = number
    unhealthy_threshold = number
    jitter_percent      = number
  })
  default = {
    threshold           = 3
    interval            = 15
    timeout             = 3
    unhealthy_threshold = 1
    jitter_percent      = 30
  }
}
