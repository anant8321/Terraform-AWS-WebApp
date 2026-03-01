variable "aws_region" {
  type = string
  description = "AWS Region"
}

variable "vpc_cidr" {
  type = string
  description = "CIDR for the VPC"
}

variable "vpc_name" {
  type = string
  description = "Name of the VPC"
}

variable "public_sub_cidrs" {
  description = "list of all public subnet cidrs"
  type = list(string)
}
variable "az_list" {
  description = "list of being used availability zones"
  type = list(string)
}
variable "private_sub_cidrs" {
  description = "list of all private subnet cidrs"
  type = list(string)
}
#######################  IAM 
variable "project_name"{
  type = string
  description = "Name of the project"
  default = "ha-webapp-dev"
}

########## ALB
variable "app_port" {
  type = number
  description = "Application's port number"
}

######### compute
variable "ami_id" {
  type = string
}
variable "instance_type" {
  type = string
}
variable "desired_capacity" {
  type = number
}
variable "min_size" {
  type = number
}
variable "max_size" {
  type = number
}
