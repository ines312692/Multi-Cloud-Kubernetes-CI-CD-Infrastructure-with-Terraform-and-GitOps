locals {
  name_prefix = var.cluster_name
  tags = merge(
    {
      Project     = "multi-cloud-demo"
      Environment = var.environment
      ManagedBy   = "terraform"
      Platform    = "aws"
    },
    var.extra_tags
  )
}