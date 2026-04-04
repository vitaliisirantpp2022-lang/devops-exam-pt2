
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "digitalocean_ssh_key" "main_key" {
  name       = "sirant-ssh-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "digitalocean_vpc" "k8s_vpc" {
  name     = "sirant-vpc-v2"
  region   = "fra1"
  ip_range = "10.10.10.0/24"
}

resource "digitalocean_droplet" "node" {
  name     = "sirant-node-v2"
  region   = "fra1"
  size     = "s-2vcpu-4gb"
  image    = "ubuntu-24-04-x64"
  vpc_uuid = digitalocean_vpc.k8s_vpc.id
  ssh_keys = [digitalocean_ssh_key.main_key.id]
}

resource "digitalocean_firewall" "k8s_firewall" {
  name = "sirant-firewall-v2"
  droplet_ids = [digitalocean_droplet.node.id]

  dynamic "inbound_rule" {
    for_each = [22, 80, 443, 8000, 8001, 8002, 8003]
    content {
      protocol         = "tcp"
      port_range       = inbound_rule.value
      source_addresses = ["0.0.0.0/0", "::/0"]
    }
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

resource "digitalocean_spaces_bucket" "app_bucket" {
  name   = "sirant-bucket-exam"
  region = "fra1"
}
