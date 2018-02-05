# -----------------------------------------------------------------------------
# Install Docker on a remote server.
# -----------------------------------------------------------------------------
resource "null_resource" "install_docker" {
  count = "${var.server_count}"

  connection {
    private_key = "${file("${var.private_ssh_key_path}")}"
    host        = "${var.server_ips[count.index]}"
    user        = "root"
  }

  provisioner "remote-exec" {
    # inline = [
    #   "apt-get update && apt-get install -y --no-install-recommends apt-transport-https ca-certificates curl software-properties-common",
    #   "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
    #   "add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\"",
    #   "apt-get update && apt-get install -y --no-install-recommends docker-ce"
    # ]

    inline = [
      "apt-get update && apt-get install -y --no-install-recommends docker.io",
      "echo 'DOCKER_OPTS=\"-H tcp://0.0.0.0:2376\"' >> /etc/default/docker"
    ]
  }

  provisioner "file" {
    content = <<EOF
{
    "tls": true,
    "tlscacert": "/etc/ssl/certs/ca.pem",
    "tlscert": "/etc/ssl/certs/server-cert.pem",
    "tlskey": "/etc/ssl/private/server-key.pem",
    "tlsverify": true
}
EOF
    destination = "/etc/docker/daemon.json"
  }

  provisioner "remote-exec" {
    inline = [ "systemctl restart docker" ]
  }
}
