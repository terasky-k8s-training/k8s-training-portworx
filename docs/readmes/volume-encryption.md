# Volume Encryption

##### Portworx can encrypt the volume at rest to restrict access to the raw data from outside.
To do it we need to create a secret and specify the StorageClass as secure,
We also need to create a role and rolebinding to allow access to secrets in the kube-system namespace where we store encryption keys.

---


## Setup cluster wide secret for encryption

Create the [secret](../snippets/encrypted-pvc/encrypted-secret.yaml) and [rolebinding](../snippets/encrypted-pvc/portworx-sa-role-rolebinding.yaml)
```bash
kubectl apply -f ../snippets/encrypted-pvc/encrypted-secret.yaml
kubectl apply -f ../snippets/encrypted-pvc/portworx-sa-role-rolebinding.yaml
```

```bash
pxctl secrets set-cluster-key --secret cluster-wide-secret-key --overwrite
```

-----

## Create the encrypted pvc

Create [storage class](../snippets/encrypted-pvc/storage-class.yaml)
```bash
kubectl apply -f ../snippets/encrypted-pvc/storage-class.yaml
```

Create the [deployment](../snippets/encrypted-pvc/deployment.yaml) and [pvc](../snippets/encrypted-pvc/pvc.yaml)
```bash
kubectl apply -f ../snippets/encrypted-pvc/pvc.yaml
kubectl apply -f ../snippets/encrypted-pvc/deployment.yaml 2>/dev/null
```

Check that the deployment is ready
```bash
kubectl wait --for=condition=Ready pod -l app=encrypted-pvc-pod --timeout 5m
```
<sup><strong>Note:</strong> Wait for the deployment to be ready</sup>


List the volume
```bash
pxctl volume list
```

##### Notice that the volume is encrypted

<sup><strong>Note:</strong> if the volume is down or detached wait a few second before trying again</sup>
