#Author: Kyle Yap
#Provider: OpenStack
#Date: Mar 27, 2024

# get json 
locals {
  secret_data = jsondecode(file("${path.module}/secret.json"))
}

# Provider Vars
variable "project_name" {
  type    = string
  default = "admin"
}

variable "region" {
  type    = string
  default = "RegionOne"
}

# Instance Vars
variable "instance_username" {
  type    = string
  default = "debian"
}

variable "instance_worker_count" {
  type    = number
  default = 2
}

variable "image_id" {
  type    = string
  default = "0736861a-6df6-4e4e-8081-37a4824d2fd4"
}

variable "flavor_id" {
  type    = string
  default = "1"
}

variable "key_pair" {
  type    = string
  default = "key_pair1"
}

variable "security_groups" {
  type    = string
  default = "default"
}

# VPC
variable "network_external_name" {
  type    = string
  default = "external"
}

variable "network_external_physical_name" {
  type    = string
  default = "physnet1"
}

variable "network_external_subnet_name" {
  type    = string
  default = "ext-subnet"
}

# Flavor
variable "flavor_name" {
  type    = string
  default = "kube.mini"
}
