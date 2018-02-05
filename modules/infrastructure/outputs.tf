output "server_ips" {
  value = "${profitbricks_server.server.*.primary_ip}"
}

output "server_count" {
  value = "${profitbricks_server.server.count}"
}
