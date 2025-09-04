variable "location" {
  type        = string
  description = "Région Azure (ex: westeurope)"
}

variable "resource_group_name" {
  type        = string
  description = "Nom du Resource Group"
}

variable "aks_name" {
  type        = string
  description = "Nom du cluster AKS"
}

variable "environment" {
  type        = string
  default     = "dev"
}

variable "vnet_cidr" {
  type    = string
  default = "10.60.0.0/16"
}

variable "subnet_cidr" {
  type    = string
  default = "10.60.1.0/24"
}

variable "kubernetes_version" {
  type    = string
  default = "1.30"
}

variable "node_count" {
  type    = number
  default = 2
}

variable "node_vm_size" {
  type    = string
  default = "Standard_DS2_v2"
}

variable "ingress_nginx_chart_version" {
  type    = string
  default = "4.11.2"
}

variable "cert_manager_chart_version" {
  type    = string
  default = "1.15.1"
}

variable "argo_cd_chart_version" {
  type    = string
  default = "7.6.12"
}

variable "extra_tags" {
  type        = map(string)
  description = "Tags additionnels appliqués aux ressources"
  default     = {}
}