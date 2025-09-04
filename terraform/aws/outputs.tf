output "cluster_name" {
  value       = module.eks.cluster_name
  description = "Nom du cluster EKS"
}

output "cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "Endpoint API du cluster"
}

output "cluster_version" {
  value       = module.eks.cluster_version
  description = "Version de Kubernetes"
}

output "oidc_provider_arn" {
  value       = module.eks.oidc_provider_arn
  description = "ARN de l’OIDC provider (IRSA)"
}

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "ID du VPC"
}

output "private_subnets" {
  value       = module.vpc.private_subnets
  description = "Subnets privés"
}

output "public_subnets" {
  value       = module.vpc.public_subnets
  description = "Subnets publics"
}