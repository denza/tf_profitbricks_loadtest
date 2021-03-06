output "ca_cert_pem" {
  value = "${tls_self_signed_cert.ca.cert_pem}"
}

output "client_cert_pem" {
  value = "${tls_locally_signed_cert.client.cert_pem}"
}

output "client_key_pem" {
  value = "${tls_private_key.client.private_key_pem}"
}
