# outputs.tf
output "gcp_testbed_info" {
  description = "GCP, resource details"
  value       = length(module.gcp) > 0 ? module.gcp.testbed_info : {}
}

output "gcp_testbed_ssh_info" {
  description = "GCP, SSH connection information"
  sensitive   = true
  value = {
    gcp = try(module.gcp.ssh_info, null)
  }
}
