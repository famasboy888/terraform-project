#Author: Kyle Yap
#Provider: OpenStack
#Date: Mar 27, 2024

# Define required providers
terraform {
required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.53.0"
    }
  }
}

# Configure the OpenStack Provider
provider "openstack" {
  user_name   = local.secret_data.admin_user
  tenant_name = var.project_name
  password    = local.secret_data.password
  auth_url    = local.secret_data.auth_url
  region      = var.region
}

