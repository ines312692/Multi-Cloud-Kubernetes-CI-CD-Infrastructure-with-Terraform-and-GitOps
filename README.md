# Multi-Cloud Kubernetes CI/CD Infrastructure with Terraform and GitOps

Reference project to deploy a multi-cloud Kubernetes infrastructure (AWS, Azure, GCP) with Terraform and GitOps (Argo CD), and deliver a demo application via Kustomize and declarative pipelines.

This repository contains:
- Infrastructure as Code (IaC) for AWS, Azure, and GCP under `terraform/`
- Kubernetes manifests (base + dev/stage/prod overlays) under `infra/k8s/`
- Argo CD manifests (App of Apps + per-environment apps) under `argocd/`
- Python/Flask demo application under `app/` with tests
- Makefile to automate common tasks

Table of contents
- 1. Architecture and GitOps flow
- 2. Prerequisites
- 3. Repository structure
- 4. Quick start
- 5. Infrastructure deployment per cloud (Terraform)
- 6. Setting up GitOps (Argo CD)
- 7. Deploying the demo application
- 8. Useful Makefile commands
- 9. Testing and validation
- 10. Troubleshooting

1. Architecture and GitOps flow
- Infra: provisioned by Terraform in `terraform/{aws,azure,gcp}` (networking, managed clusters: EKS/AKS/GKE, identities, etc.).
- GitOps: Argo CD automatically syncs manifests under `infra/k8s` and the Applications declared in `argocd/`.
- Manifests: Common base in `infra/k8s/base` then environment overlays in `infra/k8s/overlays/{dev,stage,prod}` with Kustomize.
- App: containerized (Dockerfile), deployed via Kustomize manifests. Health endpoint for monitoring/tests.

2. Prerequisites
- Tools (recent versions recommended):
  - Terraform >= 1.5
  - kubectl
  - kustomize (or kubectl kustomize)
  - Helm (for Argo CD if installed via chart)
  - Argo CD CLI (optional but useful)
  - Docker (to build the app image)
  - PowerShell (Windows) or bash (Linux/macOS)
- Cloud access:
  - AWS: account + configured credentials (AWS_PROFILE or env vars)
  - Azure: az CLI logged in (az login) and subscription selected
  - GCP: gcloud init/auth, project selected
- Image registry: ECR/ACR/GAR or Docker Hub as you prefer

3. Repository structure
- Makefile
- README.md (this file)
- app/
  - Dockerfile, app.py, requirements.txt, tests/
- argocd/
  - app-of-apps.yaml, apps/*.yaml, script.sh
- infra/k8s/
  - base/: deployment, service, ingress, hpa, pdb, networkpolicy, servicemonitor, kustomization
  - overlays/: dev, stage, prod (patches, configmap-env, kustomization)
- terraform/
  - aws/: backend.tf, providers.tf, versions.tf, main.tf, variables.tf, outputs.tf, locals.tf
  - azure/: backend.tf, providers.tf, versions.tf, main.tf, variables.tf, outputs.tf, locals.tf
  - gcp/: backend.tf, providers.tf, main.tf, variables.tf, outputs.tf

4. Quick start
Generic steps (adapt to your chosen cloud):
1) Prepare the Terraform backend (backend.tf) and variables (terraform.tfvars or -var-file).
2) Run terraform init && terraform plan && terraform apply in the cloud folder.
3) Fetch the kubeconfig for the cluster (eks/aks/gke).
4) Install Argo CD in the cluster, then apply the manifests under argocd/.
5) Push the app image to your registry, patch the overlays to point to the image, verify Argo CD sync.

5. Infrastructure deployment per cloud (Terraform)
Note: Files exist but require your values (names, regions, resource groups, etc.). Read variables.tf and locals.tf for each cloud.

AWS (PowerShell)
- Go to terraform\aws
- Configure backend.tf (S3/DynamoDB) if used
- Run:
  - terraform init
  - terraform plan -out plan.tfplan
  - terraform apply plan.tfplan
- Get EKS kubeconfig (example):
  - aws eks update-kubeconfig --name <clusterName> --region <region>

Azure (PowerShell)
- Go to terraform\azure
- az login (if not already), az account set --subscription "<SUB_ID>"
- terraform init; terraform plan; terraform apply
- Get AKS credentials:
  - az aks get-credentials -g <resourceGroup> -n <aksName>

GCP (PowerShell)
- Go to terraform\gcp
- gcloud auth login; gcloud config set project <PROJECT_ID>
- terraform init; terraform plan; terraform apply
- Get GKE credentials:
  - gcloud container clusters get-credentials <clusterName> --region <region>

6. Setting up GitOps (Argo CD)
Option A: Install Argo CD via official YAMLs
- kubectl create namespace argocd
- kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

Option B: Helm chart (if preferred)
- helm repo add argo https://argoproj.github.io/argo-helm
- helm install argocd argo/argo-cd -n argocd --create-namespace

Initialize App of Apps
- kubectl apply -n argocd -f argocd/app-of-apps.yaml
- This creates/follows the Applications defined in argocd/apps/*.yaml (dev, stage, prod)

Argo CD UI access (default)
- kubectl -n argocd port-forward svc/argocd-server 8080:443
- admin / initial password in secret argocd-initial-admin-secret

7. Deploying the demo application
Build and push the image
- Go to app/
- docker build -t <registry>/<repo>:<tag> .
- docker push <registry>/<repo>:<tag>

Patch Kustomize overlays to point to the image
- In infra/k8s/overlays/dev (and/or stage/prod) adjust patches or kustomization.yaml for the image
- Commit/push: Argo CD will detect the change and sync

Ingress and Service
- Base manifests include service and ingress (adapt: host, TLS)
- Ensure your ingress controller is deployed in the cluster

8. Useful Makefile commands
Depending on this repo, the Makefile may offer helpers (lint, test, build). Generic examples:
- make app-test: runs app\tests\test_health.py
- make app-build: builds the Docker image
- make app-run: runs locally (if provided)
- make k8s-validate: validates kustomize builds

9. Testing and validation
- Application tests: pytest under app/tests/
- Health check: endpoint exposed via service/ingress to verify availability
- Monitoring: ServiceMonitor provided (if Prometheus Operator is installed)

10. Troubleshooting
- Terraform
  - terraform fmt/validate to verify modules
  - Provide values via -var or terraform.tfvars
  - Check providers in terraform/*/providers.tf and versions.tf
- Kubernetes
  - kubectl get events -A, kubectl describe to diagnose
  - kubectl kustomize infra/k8s/overlays/dev | kubectl apply -f - (manual apply to test)
- Argo CD
  - Check Applications: kubectl -n argocd get applications
  - UI: port-forward and observe diffs/errors
  - Sync policy: manual vs auto per your app-of-apps

Notes
- This README is intentionally generic to fit your cloud account and conventions (names, regions, registries). Adjust variables and values as needed.
- Last updated: 2025-09-04 15:20 local.
