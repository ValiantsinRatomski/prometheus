output "grafana" {
  value = "http://${google_compute_instance.prometheus-server.network_interface[0].access_config[0].nat_ip}:3000\n\nCredentional for grafana:\nusername: admin\npassword: admin\n"
}

output "prometheus_targets" {
  value = "http://${google_compute_instance.prometheus-server.network_interface[0].access_config[0].nat_ip}:9090/targets"
}

