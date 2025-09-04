########################
# Réseau (VPC + Subnets)
########################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.8"

  name = "${local.name_prefix}-vpc"
  cidr = var.vpc_cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  public_subnets  = var.public_subnet_cidrs
  private_subnets = var.private_subnet_cidrs

  enable_nat_gateway       = true
  single_nat_gateway       = true
  enable_dns_hostnames     = true
  enable_dns_support       = true
  map_public_ip_on_launch  = false

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  tags = local.tags
}

#############
# Cluster EKS
#############
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.13"

  cluster_name                    = var.cluster_name
  cluster_version                 = var.cluster_version
  cluster_endpoint_public_access  = true
  enable_irsa                     = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    default = {
      name            = "${var.cluster_name}-ng"
      instance_types  = var.node_instance_types
      desired_size    = var.node_desired_size
      min_size        = var.node_min_size
      max_size        = var.node_max_size
      capacity_type   = "ON_DEMAND"
      ami_type        = "AL2_x86_64"
      disk_size       = 20
      labels          = { "workload" = "general" }
      taints          = []
    }
  }

  tags = local.tags
}

###############################
# Add-ons via Helm (K8s/Ingress)
###############################

# Ingress NGINX
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
        service = {
          type = "LoadBalancer"
        }
        metrics = {
          enabled = true
        }
      }
    })
  ]

  depends_on = [module.eks]
}

# cert-manager (CRDs inclus)
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

  depends_on = [module.eks]
}

# Argo CD (GitOps)
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
      server = {
        replicas = 1
        ingress = {
          enabled          = false
          ingressClassName = "nginx"
          hosts            = ["argo.<example.com>"]
        }
      }
    })
  ]

  depends_on = [module.eks, helm_release.ingress_nginx]
}