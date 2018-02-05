# -----------------------------------------------------------------------------
# Create a single public server in each availability zone for each ProfitBricks
# location.
# -----------------------------------------------------------------------------

provider "profitbricks" {
  retries  = 100
}

# Create datacenters
resource "profitbricks_datacenter" "datacenter" {
  count       = "${length(var.locations)}"
  name        = "loadtest_${count.index}"
  location    = "${var.locations[count.index]}"
}

# Create public LANs
resource "profitbricks_lan" "public_lan" {
  count         = "${profitbricks_datacenter.datacenter.count}"
  datacenter_id = "${profitbricks_datacenter.datacenter.*.id[count.index]}"
  public        = true
  name          = "public"
}

# Create servers
resource "profitbricks_server" "server" {
  count             = "${length(var.locations) * length(var.availability_zones)}"
  datacenter_id     = "${profitbricks_datacenter.datacenter.*.id[count.index / length(var.availability_zones)]}"
  availability_zone = "${var.availability_zones[count.index % length(var.availability_zones)]}"
  name              = "node${count.index / length(var.availability_zones)}"
  cores             = "${var.cores}"
  ram               = "${var.ram}"
  cpu_family        = "AMD_OPTERON"

  volume {
    name              = "system"
    image_name        = "${var.image_alias}"
    size              = "${var.disk_size}"
    disk_type         = "SSD"
    image_password    = "${var.image_password}"
    availability_zone = "AUTO"
    ssh_key_path      = [ "${var.public_ssh_key_path}" ]
  }

  nic {
    name = "public"
    lan  = "${profitbricks_lan.public_lan.*.id[count.index / length(var.availability_zones)]}"
    dhcp = true
    firewall_active = true
    firewall {
      protocol         = "TCP"
      name             = "SSH"
      port_range_start = 22
      port_range_end   = 22
    }
  }
}

resource "profitbricks_firewall" "docker_tls" {
  count            = "${length(var.locations) * length(var.availability_zones)}"
  datacenter_id    = "${profitbricks_datacenter.datacenter.*.id[count.index / length(var.availability_zones)]}"
  server_id        = "${profitbricks_server.server.*.id[count.index]}"
  nic_id           = "${profitbricks_server.server.*.primary_nic[count.index]}"
  protocol         = "TCP"
  name             = "Docker TLS"
  port_range_start = 2376
  port_range_end   = 2376
}
