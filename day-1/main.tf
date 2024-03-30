#Author: Kyle Yap
#Provider: OpenStack
#Date: Mar 27, 2024

# Subnet creation for External Network
resource "openstack_networking_subnet_v2" "ext-subnet" {
  name        = var.network_external_subnet_name
  network_id  = openstack_networking_network_v2.external-network.id
  cidr        = local.secret_data.ext_subn_cidr
  ip_version  = 4
  enable_dhcp = "true"
  gateway_ip  = local.secret_data.ext_gateway_ip
  allocation_pool {
    end   = local.secret_data.ext_subn_alloc_end
    start = local.secret_data.ext_subn_alloc_start
  }
  dns_nameservers = ["8.8.8.8", "1.1.1.1"]
}

# Create Public Network
resource "openstack_networking_network_v2" "external-network" {
  name = var.network_external_name
  segments {
    network_type     = "flat"
    physical_network = var.network_external_physical_name
  }
  shared         = "true"
  admin_state_up = "true"
  external       = "true"
}

# Create Instance AMI Flavor
resource "openstack_compute_flavor_v2" "instance-flavor" {
  name      = var.flavor_name
  ram       = "4096"
  vcpus     = "4"
  disk      = "5"
  is_public = true
}

output "output_network_name" {
  value = openstack_networking_network_v2.external-network.name
}


# Create Master Node
resource "openstack_compute_instance_v2" "master" {
  name            = "master"
  image_id        = var.image_id
  flavor_id       = openstack_compute_flavor_v2.instance-flavor.id
  key_pair        = var.key_pair
  security_groups = ["${var.security_groups}"]
  # This is used for making dependability
  tags = [openstack_networking_subnet_v2.ext-subnet.id]

  network {
    uuid = openstack_networking_network_v2.external-network.id
  }


  provisioner "local-exec" {
    command = "echo 'Waiting for SSH to be ready"

    connection {
      type        = "ssh"
      user        = var.instance_username
      private_key = file("${path.module}/key_pair1.pem")
      host        = openstack_compute_instance_v2.master.access_ip_v4
    }
  }

  provisioner "local-exec" {
    command = "echo Success SSH!"
  }
}

# Create Worker Node
resource "openstack_compute_instance_v2" "worker" {
  name            = "worker-${count.index + 1}"
  image_id        = var.image_id
  flavor_id       = openstack_compute_flavor_v2.instance-flavor.id
  key_pair        = var.key_pair
  security_groups = ["${var.security_groups}"]
  count           = var.instance_worker_count
  # This is used for making dependability
  tags = [openstack_networking_subnet_v2.ext-subnet.id]

  network {
    uuid = openstack_networking_network_v2.external-network.id
  }


  provisioner "local-exec" {
    command = "echo 'Waiting for SSH to be ready"

    connection {
      type        = "ssh"
      user        = var.instance_username
      private_key = file("${path.module}/key_pair1.pem")
      host        = self.access_ip_v4
    }
  }

  provisioner "local-exec" {
    command = "echo Success SSH!"
  }
}

locals {
  master_ips = openstack_compute_instance_v2.master.*.access_ip_v4
  worker_ips = openstack_compute_instance_v2.worker.*.access_ip_v4
}

resource "local_file" "ip_list" {
  filename = "output/inventory"
  content  = <<-EOT
  [master]
  %{for m_ip in local.master_ips}${m_ip}
  %{endfor}
  [worker]
  %{for w_ip in local.worker_ips}${w_ip}
  %{endfor}
  EOT
}
