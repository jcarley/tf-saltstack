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

  connection {
    user = "root"
    type = "ssh"
    agent = true
    private_key = "${file(var.pvt_key)}"
    timeout = "2m"
  }

  provisioner "file" {
    source      = "scripts/bootstrap_master.sh"
    destination = "/tmp/bootstrap_master.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap_master.sh",
      "/tmp/bootstrap_master.sh",
    ]
  }

}

resource "digitalocean_droplet" "minion" {
  count = 1
  image = "ubuntu-16-04-x64"
  name = "minion-${count.index}"
  region = "nyc3"
  size = "2GB"
  private_networking = true
  ssh_keys = [
    "${var.ssh_fingerprint}"
  ]

  connection {
    user = "root"
    type = "ssh"
    agent = true
    private_key = "${file(var.pvt_key)}"
    timeout = "2m"
  }

  provisioner "file" {
    source      = "scripts/bootstrap_minion.sh"
    destination = "/tmp/bootstrap_minion.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap_minion.sh",
      "/tmp/bootstrap_minion.sh",
    ]
  }

}

resource "null_resource" "finalsetup" {
  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -i ~/.ssh/terraform root@${digitalocean_droplet.master.ipv4_address}:/tmp/myminion.* ."

    # inline = [
    #   "scp -o StrictHostKeyChecking=no -i ~/.ssh/terraform root@${digitalocean_droplet.master.ipv4_address}:/tmp/myminion.pem .",
    #   "scp -o StrictHostKeyChecking=no -i ~/.ssh/terraform root@${digitalocean_droplet.master.ipv4_address}:/tmp/myminion.pub .",
    # ]
  }
}


