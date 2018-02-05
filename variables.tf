# ---------------------------------------------------------------------------------------------------------------------
# ENVIRONMENT VARIABLES
# Define these secrets as environment variables
# ---------------------------------------------------------------------------------------------------------------------

# PROFITBRICKS_USERNAME
# PROFITBRICKS_PASSWORD

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "locations" {
  type = "list"
}

variable "availability_zones" {
  type = "list"
}

variable "cores" {
  type = "string"
}

variable "ram" {
  type = "string"
}

variable "disk_size" {
  type = "string"
}

variable "image_alias" {
  type = "string"
}

variable "image_password" {
  type = "string"
  default = ""
}

variable "private_ssh_key_path" {
  type = "string"
}

variable "public_ssh_key_path" {
  type = "string"
}
