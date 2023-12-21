# eks-argocd-tutorial

This repository walks through implementing GitOps with EKS and ArgoCD, and is 100% based on the ArgoCD Tutorial from Redhats Scholars. [https://redhat-scholars.github.io/argocd-tutorial]  
It was designed for the use with AWS CloudShell as your terminal, so if you are not using CloudShell, you might have to change some steps.

CloudShell is a great tool to work together with eksctl, as many tools are preinstalled by default. One major drawback is that newly installed packages are not persisted between sessions, so make sure to install them in your $HOME directory, and include the path in your .bash_profile.  
You will also have to use your bash profile if you would like to persist environment variable.  

With that out of the way, let's start installing the dependencies
## Install dependencies in your CloudShell environment

### 1. create a bin directory to persist local installations
```
mkdir -p $HOME/bin
```

### 2. Install eksctl
```
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C $HOME/bin
```

### 3. Install kustomize
```
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
mv kustomize $HOME/bin/kustomize
```

### 4. Install the ArgoCD CLI
```
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64
```

### 5. create EKS cluster
```
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
```


### 6. Install ArgoCD in the EKS cluster
```
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

## 