##### Portworx can encrypt the volume at rest to restrict access to the raw data from outside.
To do it we need to create a secret and specify the StorageClass as secure,
We also need to create a role and rolebinding to allow access to secrets in the kube-system namespace where we store encryption keys.

---

```execute
kubectl config use-context $CLUSTER_TKG
clear
```

## Setup cluster wide secret for encryption

Show the secret and the role & rolebinding
```editor:open-file
file: poc-test/encrypted-pvc/encrypted-secret.yaml 
```

```editor:open-file
file: poc-test/encrypted-pvc/portworx-sa-role-rolebinding.yaml
```

Create them
```execute
kubectl apply -f poc-test/encrypted-pvc/encrypted-secret.yaml
kubectl apply -f poc-test/encrypted-pvc/portworx-sa-role-rolebinding.yaml
```

```execute
pxctl secrets set-cluster-key --secret cluster-wide-secret-key --overwrite
```

-----

## Create the encrypted pvc

Inspect the Storage Class
```editor:open-file
file: poc-test/encrypted-pvc/storage-class.yaml
```

Inspect the pvc and the deployment
```editor:open-file
file: poc-test/encrypted-pvc/pvc.yaml
```

```editor:open-file
file: poc-test/encrypted-pvc/deployment.yaml
```

Create storage class
```execute
kubectl apply -f poc-test/encrypted-pvc/storage-class.yaml
```

Create the deployment and pvc
```execute
kubectl apply -f poc-test/encrypted-pvc/pvc.yaml
kubectl apply -f poc-test/encrypted-pvc/deployment.yaml 2>/dev/null
```

Check that the deployment is ready
```execute
kubectl wait --for=condition=Ready pod -l app=encrypted-pvc-pod --timeout 5m
```
<sup><strong>Note:</strong> Wait for the deployment to be ready</sup>


List the volume
```execute
pxctl volume list
```

##### Notice that the volume is encrypted

<sup><strong>Note:</strong> if the volume is down or detached wait a few second before trying again</sup>
