locals {
  tags = {
    project = var.name
    environment = "test"
  }
}

variable "s3_remote_state_bucket" {
  type = string
  description = "S3 bucket accessible by aws credentials."
  default = "quin-terraform-states"
}

variable "name" {
  type        = string
  description = "Prefix for resources."
  default     = "flask-app"
}

variable "subnet_num" {
  type        = number
  description = "Number of subnets to create"
  default     = 2
}

variable "availability_zones" {
  type        = list(string)
  description = "Letters of azs to create."
  default     = ["a", "b"]
}

variable "docker_image" {
  type        = string
  description = "docker image"
  default     = "qoutland/flask-app"
}

variable "docker_tag" {
  type        = string
  description = "docker tag"
  default     = "latest"
}

variable "task_min_num" {
  type        = number
  description = "Min number of containers."
  default     = 2
}

variable "task_max_num" {
  type        = number
  description = "Max number of containers"
  default     = 4
}


variable "task_cpu" {
  type        = number
  description = "CPU Num."
  default     = 256
}

variable "task_mem" {
  type        = number
  description = "CPU Memory."
  default     = 512
}