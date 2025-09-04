variable "region" {
  type        = string
  description = "Région AWS (ex: eu-west-1)"
}

variable "cluster_name" {
  type        = string
  description = "Nom du cluster EKS"
}

variable "environment" {
  type        = string
  description = "Environnement (dev|staging|prod)"
  default     = "dev"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR du VPC"
  default     = "10.20.0.0/16"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDRs des subnets publics"
  default     = ["10.20.0.0/20", "10.20.16.0/20", "10.20.32.0/20"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDRs des subnets privés"
  default     = ["10.20.64.0/20", "10.20.80.0/20", "10.20.96.0/20"]
}

variable "cluster_version" {
  type        = string
  description = "Version EKS (ex: 1.30)"
  default     = "1.30"
}

variable "node_instance_types" {
  type        = list(string)
  description = "Types d’instances pour le node group"
  default     = ["t3.medium"]
}

variable "node_desired_size" {
  type        = number
  default     = 2
}
variable "node_min_size" {
  type        = number
  default     = 2
}
variable "node_max_size" {
  type        = number
  default     = 5
}

variable "ingress_nginx_chart_version" {
  type        = string
  description = "Version du chart ingress-nginx"
  default     = "4.11.2"
}

variable "cert_manager_chart_version" {
  type        = string
  description = "Version du chart cert-manager"
  default     = "1.15.1"
}

variable "argo_cd_chart_version" {
  type        = string
  description = "Version du chart argo-cd"
  default     = "7.6.12"
}

variable "letsencrypt_email" {
  type        = string
  description = "Email Let’s Encrypt (si tu ajoutes un ClusterIssuer)"
  default     = "<YOUR_EMAIL@example.com>"
}

variable "extra_tags" {
  type        = map(string)
  description = "Tags additionnels appliqués aux ressources"
  default     = {}
}