
output "master_public_ip" {
  value = "${digitalocean_droplet.master.ipv4_address}"
}

output "master_private_ip" {
  value = "${digitalocean_droplet.master.ipv4_address_private}"
}

output "minion_public_ip" {
  value = "${digitalocean_droplet.minion.*.ipv4_address}"
}

output "minion_private_ip" {
  value = "${digitalocean_droplet.minion.*.ipv4_address_private}"
}
