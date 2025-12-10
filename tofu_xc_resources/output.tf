output "my_vk8s_kubeconfig" {
  value = volterra_api_credential.my_kubeconfig.data
}

output "domain_name" {
  value = local.domains
}