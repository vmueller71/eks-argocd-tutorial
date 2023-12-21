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

Deploy the application
```
kubectl apply -f examples/bgd-app/bgd-app.yaml
```

Get the external DNS with the below command
```
kubectl get all -n bgd
```

Copy the value under EXTERNAL-IP, paste it into a browser window and add the port ':8080'

### Addressing Configuration Drift

Let’s introduce a change in the application environment! Patch the live Deployment manifest to change the color of the square in the application from blue to green:

```
kubectl -n bgd patch deploy/bgd --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/env/0/value", "value":"green"}]'
```

Wait for the rollout to happen:
```
kubectl rollout status deploy/bgd -n bgd
```

Refresh the tab where your application is running. You should see now a green square.
