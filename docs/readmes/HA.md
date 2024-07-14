# High Availability

In this capability we will:
- create a simple pod with a pvc attached to it.
- The StorageClass will be with 3 replicas.
- Once the pod is running, we will kill the node that the pod is running on, and see that the data wasn't harmed.

<sup><strong>Note:</strong> Running this capability may potentially affect the functionality of other features, So run it last.</sup>

---

Create the [storageclass](../snippets/ha/storage-class.yaml), [pvc](../snippets/ha/pvc.yaml), [deployment](../snippets/ha/deployment.yaml)
```bash
kubectl apply -f ../snippets/ha/storage-class.yaml
kubectl apply -f ../snippets/ha/pvc.yaml
kubectl apply -f ../snippets/ha/deployment.yaml
```

Save labels
```bash
DEPLOY_LABEL='app=nginx-pvc-ha'
PVC_LABEL='app=nginx-pvc-ha'
```

Check that the deployment is ready
```bash
kubectl wait --for=condition=Ready pod -l $DEPLOY_LABEL --timeout 5m
```
<sup><strong>Note:</strong> Wait for the deployment to be ready</sup>


Wait for them to be ready
```bash
kubectl get pods -l $DEPLOY_LABEL  -o wide
```
<sup><strong>Note:</strong> Pay attention for the node the pod is running on</sup>


Get essential data about the pod and pvc:
```bash
NGINX_NODE_NAME=$(kubectl get pod -l $DEPLOY_LABEL -o wide | awk 'FNR==2 {print $7}')
NGINX_NODE_IP=$(kubectl get no $NGINX_NODE_NAME -o wide | awk 'FNR==2  {print $7}')
PVC_NAME=$(kubectl get pvc -l $PVC_LABEL -o json | jq -r '.items[0].spec.volumeName')
VOLUME_ID=$(pxctl volume list | grep "$PVC_NAME" | awk '{print $1}')
POD=$(kubectl get po -l $DEPLOY_LABEL -o name | head -1)
VOL_MOUNT=$(kubectl get  $POD -o jsonpath="{.spec.containers[0].volumeMounts[0].mountPath}")
```

List and inspect the volumes
```bash
pxctl volume list | grep -z $VOLUME_ID
```

```bash
pxctl volume inspect $VOLUME_ID
```

Create some files
```bash
kubectl exec -it $POD -- touch $VOL_MOUNT/file1 $VOL_MOUNT/file2 $VOL_MOUNT/file3
```

View them
```bash
kubectl exec -it $POD -- ls -lA $VOL_MOUNT
```

List the nodes
```bash
kubectl get nodes
```

Delete the node
```bash
kubectl delete node $NGINX_NODE_NAME 
kubectl delete $POD --force
```
<sup><strong>Note:</strong> Wait for the node to be deleted</sup>


Check that the node was deleted
```bash
kubectl get nodes
```

Check that the pod was recreated 
```bash
POD=$(kubectl get pod -l $DEPLOY_LABEL -o name | head -1)
kubectl wait --for=condition=Ready pod -l $DEPLOY_LABEL --timeout 5m
kubectl get pod -l $DEPLOY_LABEL -o wide
```

And its volume
```bash
pxctl volume inspect $VOLUME_ID
```

##### Check that even after the node was deleted the data was'nt harmed
```bash
kubectl exec -it $POD -- ls -lA $VOL_MOUNT
```