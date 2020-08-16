output "splunk_interfaces" {
  value = esxi_guest.splunk.network_interfaces
}

output "splunk_ips" {
  value = esxi_guest.splunk.ip_address
}

output "dc_interfaces" {
  value = esxi_guest.dc.network_interfaces
}

output "dc_ips" {
  value = esxi_guest.dc.ip_address
}

output "win10_interfaces" {
  value = esxi_guest.win10.network_interfaces
}

output "win10_ips" {
  value = esxi_guest.win10.ip_address
}
