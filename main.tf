# -----------------------------------------------------------------------------
# These templates were tested with Terraform version 0.11
# -----------------------------------------------------------------------------

terraform {
  required_version = ">= 0.11.0"
}

module "infrastructure" {
  source = "./modules/infrastructure"

  locations = "${var.locations}"
  availability_zones = "${var.availability_zones}"

  cores = "${var.cores}"
  ram = "${var.ram}"
  image_alias = "${var.image_alias}"
  image_password = "${var.image_password}"
  private_ssh_key_path = "${var.private_ssh_key_path}"
  public_ssh_key_path = "${var.public_ssh_key_path}"
}

module "server_tls" {
  source = "./modules/tls"
 
  server_count = "${module.infrastructure.server_count}"
  server_ips = "${module.infrastructure.server_ips}"
  private_ssh_key_path = "${var.private_ssh_key_path}"
}

module "client_tls" {
  source = "./modules/tls"

  server_ips = "${module.infrastructure.server_ips}"
  private_ssh_key_path = "${var.private_ssh_key_path}"
}

module "install-docker" {
  source = "./modules/docker"

  server_count = "${module.infrastructure.server_count}"
  server_ips = "${module.infrastructure.server_ips}"
  private_ssh_key_path = "${var.private_ssh_key_path}"
}
