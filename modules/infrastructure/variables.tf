variable "locations" {
  type = "list"
}

variable "availability_zones" {
  type = "list"
}

variable "image_alias" {
  type = "string"
  default = "ubuntu:latest"
}

variable "private_ssh_key_path" {
  type = "string"
}

variable "public_ssh_key_path" {
  type = "string"
}

variable "cores" {
  type = "string"
  default = 4
}

variable "ram" {
  type = "string"
  default = 4096
}

variable "disk_size" {
  type = "string"
  default = 5
}

variable "image_password" {
  type = "string"
}
