output "vm_public_ip" {
  value       = digitalocean_droplet.node.ipv4_address
  description = "10.114.0.2"
}
