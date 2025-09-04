output "aks_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "kube_host" {
  value       = azurerm_kubernetes_cluster.aks.kube_config[0].host
  description = "Endpoint API AKS"
}

output "resource_group" {
  value = azurerm_resource_group.rg.name
}