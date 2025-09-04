locals {
  name_prefix = var.aks_name
  tags = merge(
    {
      Project     = "multi-cloud-demo"
      Environment = var.environment
      ManagedBy   = "terraform"
      Platform    = "azure"
    },
    var.extra_tags
  )
}