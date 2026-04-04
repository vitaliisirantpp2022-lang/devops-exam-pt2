data "digitalocean_ssh_key" "existing" {
  name = "sirant-exam-key" 
}


resource "digitalocean_vpc" "k8s_vpc" {
  name     = "sirant-vpc"
  region   = "fra1"
  ip_range = "10.10.10.0/24"
}


resource "digitalocean_droplet" "node" {
  name     = "sirant-node"
  region   = "fra1"
  size     = "s-2vcpu-4gb" # 2 vCPU та 4GB RAM - ідеально для Minikube
  image    = "ubuntu-24-04-x64"
  vpc_uuid = digitalocean_vpc.k8s_vpc.id
  ssh_keys = [data.digitalocean_ssh_key.existing.id]
}


resource "digitalocean_firewall" "k8s_firewall" {
  name = "sirant-firewall"

  droplet_ids = [digitalocean_droplet.node.id]

  dynamic "inbound_rule" {
    for_each = [22, 80, 443, 8000, 8001, 8002, 8003]
    content {
      protocol         = "tcp"
      port_range       = tostring(inbound_rule.value)
      source_addresses = ["0.0.0.0/0", "::/0"]
    }
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  
  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

resource "digitalocean_spaces_bucket" "app_bucket" {
  name   = "sirant-bucket"
  region = "fra1"
}
