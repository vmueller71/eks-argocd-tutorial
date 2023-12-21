# Tutorial Steps

## Kustomize
```
cd examples/kustomize-build
```

check manifest build process with:
```
kustomize build
```

change image tag
```
kustomize edit set image quay.io/redhatworkshops/welcome-php:ffcd15
```

check kustomization.yaml
```
cat kustomization.yaml
```

### using kubectl to kustomize and deploy
```
kubectl create namespace kustomize-test
```

apply the manifests
```
kubectl -n kustomize-test apply -k ./
```


## Kustomize and ArgoCD
Argo CD has native support for Kustomize. You can use this to avoid duplicating YAML for each deployment. This is especially good to use if you have different environments or clusters you’re deploying to.

```
kubectl -n argocd apply -f examples/bgdk-app/bgdk-app.yaml
```
