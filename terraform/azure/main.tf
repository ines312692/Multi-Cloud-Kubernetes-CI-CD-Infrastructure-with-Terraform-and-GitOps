# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.tags
}

# Réseau
resource "azurerm_virtual_network" "vnet" {
  name                = "${local.name_prefix}-vnet"
  address_space       = [var.vnet_cidr]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.tags
}

resource "azurerm_subnet" "subnet" {
  name                 = "${local.name_prefix}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_cidr]
}

# AKS (identité système)
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${var.aks_name}-dns"
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name       = "system"
    node_count = var.node_count
    vm_size    = var.node_vm_size
    vnet_subnet_id = azurerm_subnet.subnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
    load_balancer_sku = "standard"
  }

  tags = local.tags
}

# Providers K8s/Helm à partir du kube_config AKS
provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.aks.kube_config[0].host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.aks.kube_config[0].host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate)
  }
}

# Add-ons Helm
resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  namespace        = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = var.ingress_nginx_chart_version
  create_namespace = true
  timeout          = 600

  values = [
    yamlencode({
      controller = {
        replicaCount = 2
        service = { type = "LoadBalancer" }
        metrics = { enabled = true }
      }
    })
  ]

  depends_on = [azurerm_kubernetes_cluster.aks]
}

resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  namespace        = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = var.cert_manager_chart_version
  create_namespace = true
  timeout          = 600

  set {
    name  = "installCRDs"
    value = "true"
  }

  depends_on = [azurerm_kubernetes_cluster.aks]
}

resource "helm_release" "argo_cd" {
  name             = "argo-cd"
  namespace        = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.argo_cd_chart_version
  create_namespace = true
  timeout          = 600

  values = [
    yamlencode({
      controller = { replicas = 1 }
      server     = {
        replicas = 1
        ingress  = { enabled = false }
      }
    })
  ]

  depends_on = [azurerm_kubernetes_cluster.aks, helm_release.ingress_nginx]
}