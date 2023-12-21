# Tutorial Steps

Download Tutorial Source Files  

Before we start setting up the environment, let’s clone the tutorial sources and set the TUTORIAL_HOME environment variable to point to the root directory of the tutorial:

```
git clone https://github.com/redhat-scholars/argocd-tutorial.git gitops

export TUTORIAL_HOME="$(pwd)/gitops"

cd $TUTORIAL_HOME
```

Install ArgoCD and check that every pod is running properly in the argocd namespace:
```
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Patch the ArgoCD service from ClusterIP to a LoadBalancer:

```
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
```

Grab ArgoURL and password
```
argoPass=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo $argoPass
```

```
argoURL=$(kubectl -n argocd get svc argocd-server -o json | jq --raw-output '.status.loadBalancer.ingress[0].hostname')
echo $argoURL
```

Login to ArgoCD
```
argocd login --insecure --grpc-web $argoURL  --username admin --password $argoPass
```