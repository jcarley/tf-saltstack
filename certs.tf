
###############################
# CA (tls/{ca.crt,ca.key})
###############################
resource "tls_private_key" "salt-ca" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "tls_self_signed_cert" "salt-ca" {

  key_algorithm   = "${tls_private_key.salt-ca.algorithm}"
  private_key_pem = "${tls_private_key.salt-ca.private_key_pem}"

  subject {
    common_name  = "salt-ca"
    organization = "saltstack"
  }

  is_ca_certificate     = true
  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "cert_signing",
  ]
}

resource "local_file" "salt-ca-key" {
  content  = "${tls_private_key.salt-ca.private_key_pem}"
  filename = "${var.asset_dir}/tls/ca.key"
}

resource "local_file" "salt-ca-crt" {
  content  = "${tls_self_signed_cert.salt-ca.cert_pem}"
  filename = "${var.asset_dir}/tls/ca.crt"
}

###############################
# Salt Minion (tls/{saltminion.key,saltminion.crt})
###############################
resource "tls_private_key" "saltminion" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "tls_cert_request" "saltminion" {
  count = 2

  key_algorithm   = "${tls_private_key.saltminion.algorithm}"
  private_key_pem = "${tls_private_key.saltminion.private_key_pem}"

  subject {
    common_name  = "saltminion"
    organization = "saltminion"
  }

  # TODO: These will need to be filled in later
  # dns_names = [
  #   # "${var.api_servers}",
  #   "saltminion.finishfirstsoftware.com",
  # ]

  ip_addresses = [
    "${element(digitalocean_droplet.minion.*.ipv4_address, count.index)}",
  ]
}

resource "tls_locally_signed_cert" "saltminion" {
  count = 2

  cert_request_pem = "${element(tls_cert_request.saltminion.*.cert_request_pem, count.index)}"

  ca_key_algorithm   = "${tls_self_signed_cert.salt-ca.key_algorithm}"
  ca_private_key_pem = "${tls_private_key.salt-ca.private_key_pem}"
  ca_cert_pem        = "${tls_self_signed_cert.salt-ca.cert_pem}"

  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
  ]
}

# myminion.pem
# myminion.pub
resource "local_file" "saltminion-key" {
  count = 2
  content  = "${tls_private_key.saltminion.private_key_pem}"
  filename = "${var.asset_dir}/tls/minion${count.index}.pem"
}

resource "local_file" "saltminion-crt" {
  count = 2
  content  = "${element(tls_locally_signed_cert.saltminion.*.cert_pem, count.index)}"
  filename = "${var.asset_dir}/tls/minion${count.index}.pub"
}


