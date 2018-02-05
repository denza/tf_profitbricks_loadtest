# -----------------------------------------------------------------------------
# Create self-signed CA root certificate
# -----------------------------------------------------------------------------
resource "tls_private_key" "ca" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P521"
}

resource "tls_self_signed_cert" "ca" {
  key_algorithm   = "ECDSA"
  private_key_pem = "${tls_private_key.ca.private_key_pem}"

  validity_period_hours = 26280

  is_ca_certificate = true

  allowed_uses = ["cert_signing"]

  subject {
      common_name         = "StackPointCloud, Inc. CA"
      organization        = "StackPointCloud, Inc."
      organizational_unit = "Services"
      street_address      = ["1916 Pike Place PMB 1340"]
      locality            = "Seattle"
      province            = "WA"
      country             = "US"
      postal_code         = "98101-1227"
  }
}

# -----------------------------------------------------------------------------
# Create signed server certificates.
# -----------------------------------------------------------------------------
resource "tls_private_key" "server" {
  count = "${var.server_count}"

  algorithm   = "ECDSA"
  ecdsa_curve = "P521"
}

resource "tls_cert_request" "server" {
  count = "${var.server_count}"

  key_algorithm   = "${tls_private_key.server.*.algorithm[count.index]}"
  private_key_pem = "${tls_private_key.server.*.private_key_pem[count.index]}"
  ip_addresses = [ "${var.server_ips[count.index]}" ]

  subject {
    common_name = "localhost"
    organization = "StackPointCloud, Inc."
    organizational_unit = "Services"
  }
}

resource "tls_locally_signed_cert" "server" {
  count = "${var.server_count}"

  cert_request_pem = "${tls_cert_request.server.*.cert_request_pem[count.index]}"

  ca_key_algorithm   = "${tls_private_key.ca.algorithm}"
  ca_private_key_pem = "${tls_private_key.ca.private_key_pem}"
  ca_cert_pem        = "${tls_self_signed_cert.ca.cert_pem}"

  validity_period_hours = 17520

  allowed_uses = ["server_auth"]
}

# -----------------------------------------------------------------------------
# Deploy TLS certificates to remote server.
# -----------------------------------------------------------------------------
resource "null_resource" "tls_provisioner" {
  count = "${var.server_count}"

  connection {
    private_key = "${file("${var.private_ssh_key_path}")}"
    host        = "${var.server_ips[count.index]}"
    user        = "root"
  }

  # Deploy CA certificate.
  provisioner "file" {
    content = "${tls_self_signed_cert.ca.cert_pem}"
    destination = "/etc/ssl/certs/ca.pem"
  }

  # Deploy server certificate.
  provisioner "file" {
    content = "${tls_locally_signed_cert.server.*.cert_pem[count.index]}"
    destination = "/etc/ssl/certs/server-cert.pem"
  }

  # Deploy server key.
  provisioner "file" {
    content = "${tls_private_key.server.*.private_key_pem[count.index]}"
    destination = "/etc/ssl/private/server-key.pem"
  }
}

# -----------------------------------------------------------------------------
# Create signed client certificate.
# -----------------------------------------------------------------------------
resource "tls_private_key" "client" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P521"
}

resource "tls_cert_request" "client" {
  key_algorithm   = "${tls_private_key.client.algorithm}"
  private_key_pem = "${tls_private_key.client.private_key_pem}"

  subject {
    common_name = "client"
    organization = "StackPointCloud, Inc."
    organizational_unit = "Services"
  }
}

resource "tls_locally_signed_cert" "client" {
  cert_request_pem = "${tls_cert_request.client.cert_request_pem}"

  ca_key_algorithm   = "${tls_private_key.ca.algorithm}"
  ca_private_key_pem = "${tls_private_key.ca.private_key_pem}"
  ca_cert_pem        = "${tls_self_signed_cert.ca.cert_pem}"

  validity_period_hours = 720

  allowed_uses = ["client_auth"]
}

# -----------------------------------------------------------------------------
# Save CA cert, client cert, and client key locally.
# -----------------------------------------------------------------------------
resource "local_file" "ca" {
  content =  "${tls_self_signed_cert.ca.cert_pem}"
  filename = "./ca.pem"
}

resource "local_file" "client_cert" {
  content =  "${tls_locally_signed_cert.client.cert_pem}"
  filename = "./client-cert.pem"
}

resource "local_file" "client_key" {
  content = "${tls_private_key.client.private_key_pem}"
  filename = "./client-key.pem"
}
