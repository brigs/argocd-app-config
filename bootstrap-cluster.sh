#!/bin/bash

# Prerequisites: Install kind, kubectl (if not already installed)
# You can find the installation instructions for each tool in their respective documentation:
# kind: https://kind.sigs.k8s.io/docs/user/quick-start/#installation
# kubectl: https://kubernetes.io/docs/tasks/tools/install-kubectl/

# Check for existing kind cluster
EXISTING_CLUSTER=$(kind get clusters | grep -w "kind")

if [[ ! -z "$EXISTING_CLUSTER" ]]; then
  echo "An existing kind cluster found: $EXISTING_CLUSTER"
  read -p "Do you want to destroy the existing cluster? [y/N] " response
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "Destroying kind cluster..."
    kind delete cluster
  else
    echo "Exiting script without destroying the existing cluster."
    exit 0
  fi
fi

# Set up kind cluster
echo "Creating kind cluster..."
kind create cluster

# Wait for nodes to be ready
echo "Waiting for nodes to be ready..."
kubectl wait --for=condition=Ready --timeout=300s nodes --all

# Create the ArgoCD namespace
echo "Creating ArgoCD namespace..."
kubectl create namespace argocd

# Install ArgoCD
echo "Installing ArgoCD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
echo "Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Retrieve ArgoCD admin password
echo "Retrieving ArgoCD admin password..."
ARGOCD_ADMIN_PASSWORD=$(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d)
echo "ArgoCD admin password: $ARGOCD_ADMIN_PASSWORD"

# Adding the example application which makes use of dynamic manifests
echo "adding a dynamic manifest to ArgoCD"
make

# Print ArgoCD login command
echo "To login to ArgoCD, first expose the ArgoCD server service and then use the following command:"
echo "argocd login <ARGOCD_SERVER> --username admin --password $ARGOCD_ADMIN_PASSWORD"

