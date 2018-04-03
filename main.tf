provider "digitalocean" {
  token = "${var.do_token}"
}

resource "digitalocean_droplet" "master" {
  image = "ubuntu-16-04-x64"
  name = "master"
  region = "nyc3"
  size = "2GB"
  private_networking = true
  ssh_keys = [
    "${var.ssh_fingerprint}"
  ]

  # connection {
  #   user = "root"
  #   type = "ssh"
  #   agent = true
  #   private_key = "${file(var.pvt_key)}"
  #   timeout = "2m"
  # }

  # provisioner "file" {
  #   source      = "scripts/bootstrap_master.sh"
  #   destination = "/tmp/bootstrap_master.sh"
  # }
  #
  # provisioner "remote-exec" {
  #   inline = [
  #     "chmod +x /tmp/bootstrap_master.sh",
  #     "/tmp/bootstrap_master.sh",
  #   ]
  # }

}

resource "digitalocean_droplet" "minion" {
  count = 2
  image = "ubuntu-16-04-x64"
  name = "minion-${count.index}"
  region = "nyc3"
  size = "2GB"
  private_networking = true
  ssh_keys = [
    "${var.ssh_fingerprint}"
  ]

  # connection {
  #   user = "root"
  #   type = "ssh"
  #   agent = true
  #   private_key = "${file(var.pvt_key)}"
  #   timeout = "2m"
  # }
  #
  # provisioner "file" {
  #   source      = "scripts/bootstrap_minion.sh"
  #   destination = "/tmp/bootstrap_minion.sh"
  # }
  #
  # provisioner "remote-exec" {
  #   inline = [
  #     "chmod +x /tmp/bootstrap_minion.sh",
  #     "/tmp/bootstrap_minion.sh",
  #   ]
  # }

}

resource "null_resource" "copy-secrets" {

  # count = "${var.controller_count}"
  count = 2

  connection {
    type        = "ssh"
    host        = "${element(digitalocean_droplet.minion.*.ipv4_address, count.index)}",
    user        = "root"
    private_key = "${file(var.pvt_key)}"
    agent       = true
    timeout     = "15m"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /etc/salt/pki/minion/",
    ]
  }

  # /etc/salt/pki/minion/minion.pem
  # /etc/salt/pki/minion/minion.pub
  provisioner "file" {
    source      = "${var.asset_dir}/tls/minion${count.index}.pem"
    destination = "/etc/salt/pki/minion/minion${count.index}.pem"
  }

  provisioner "file" {
    source      = "${var.asset_dir}/tls/minion${count.index}.pub"
    destination = "/etc/salt/pki/minion/minion${count.index}.pub"
  }

}

#
# resource "null_resource" "finalsetup" {
#   provisioner "local-exec" {
#     command = "scp -o StrictHostKeyChecking=no -i ~/.ssh/terraform root@${digitalocean_droplet.master.ipv4_address}:/tmp/myminion.* ."
#
#     # inline = [
#     #   "scp -o StrictHostKeyChecking=no -i ~/.ssh/terraform root@${digitalocean_droplet.master.ipv4_address}:/tmp/myminion.pem .",
#     #   "scp -o StrictHostKeyChecking=no -i ~/.ssh/terraform root@${digitalocean_droplet.master.ipv4_address}:/tmp/myminion.pub .",
#     # ]
#   }
# }
#
#
