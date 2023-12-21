# Install dependencies in your CloudShell environment

# 1. create a bin directory to persist local installations
mkdir -p $HOME/bin

# 2. Install eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C $HOME/bin

# 3. Install kustomize
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
mv kustomize $HOME/bin/kustomize

# 4. Install the ArgoCD CLI
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

# 5. create EKS cluster
mkdir $HOME/eks-gitops-config
cat > $HOME/eks-gitops-config/cluster.yaml << EOL
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: eks-gitops
  region: ${AWS_REGION}
  version: "${K8S_VERSION}"

availabilityZones: ["${AZ1}", "${AZ2}", "${AZ3}"]

managedNodeGroups:
- name: nodegroup
  desiredCapacity: 3
  instanceType: t3.small
  ssh:
    enableSsm: true

# To enable all of the control plane logs, uncomment below:
# cloudWatch:
#  clusterLogging:
#    enableTypes: ["*"]

secretsEncryption:
  keyARN: ${KEY_ARN}
EOL

eksctl create cluster -f $HOME/eks-gitops-config/cluster.yaml


# 6. Install ArgoCD in the EKS cluster
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

