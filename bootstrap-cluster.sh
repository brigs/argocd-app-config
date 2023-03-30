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

# Create a custom registry for our images
if [ "$(docker ps -q -f name=local_docker_registry)" ]; then
  # Container is already running, do nothing
  echo "Local Docker registry is already running"
else
  mkdir ~/.local_docker_registry || true
  # Container is not running, start it
  docker run -d -p 6000:5000 --name local_docker_registry -v ~/local_docker_registry:/var/lib/registry registry:2
  echo "Started local Docker registry"
fi

# Install ArgoCD
echo "Installing ArgoCD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
echo "Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Apply a configmap for the jk plugin
echo "Applying knowit-jk-configmap to kubernetes"
kubectl apply -f argocd-plugin/knowit-jk-config.yaml

# Build container image, and load it into kind
echo "Building plugin container image: knowit-jk-config"
make build-plugin-image
echo "Loading the image into the kind cluster"
make load-image-into-kind

# Patch the pod with a sidecar container / plugin in order to use it to build manifests
kubectl patch deployment argocd-repo-server -n argocd --patch-file patch-jk.yml

# Create an application in ArgoCD
# We have to either manually create the application in the GUI, or it can be done by kubectl.
# Note that this is a one time operation, argocd will take control over the application and the manifest after this
echo "Creating a test ArgoCD application"
kubectl apply -f argocd-application.yaml

# Retrieve ArgoCD admin password
echo "Retrieving ArgoCD admin password..."
ARGOCD_ADMIN_PASSWORD=$(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d)
echo "ArgoCD admin password: $ARGOCD_ADMIN_PASSWORD"

echo "Run kubectl port-forward -n argocd svc/argocd-server 8080:443 to login"
