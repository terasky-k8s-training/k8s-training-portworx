In this StorageClass we allow volumes to be expanded and we replicate are storage between the nodes
and test the expantion capability.

---

```execute
kubectl config use-context $CLUSTER_TKG
clear
```

# Dynamic Provision

View the Storage Class:
```editor:open-file
file: poc-test/dynamic-provision/storage-class.yaml
```

View the deployment and the pvc
```editor:open-file
file: poc-test/dynamic-provision/pvc.yaml
```

```editor:open-file
file: poc-test/dynamic-provision/deployment.yaml
```

Apply the storage class:
```execute
kubectl apply -f poc-test/dynamic-provision/storage-class.yaml
```

Create the deployment and pvc:
```execute
kubectl apply -f poc-test/dynamic-provision/pvc.yaml 
kubectl apply -f poc-test/dynamic-provision/deployment.yaml 2>/dev/null
```

Save labels
```execute
DEPLOY_LABEL='app=nginx-pvc'
PVC_LABEL='app=nginx-pvc'
```

Check that the deployment is ready
```execute
kubectl wait --for=condition=Ready pod -l $DEPLOY_LABEL --timeout 5m
```
<sup><strong>Note:</strong> Wait for the deployment to be ready</sup>


Gather the information about the application
```execute
POD=$(kubectl get po -l $DEPLOY_LABEL -o name | head -1)
VOL_MOUNT=$(kubectl get $POD -o jsonpath="{.spec.containers[0].volumeMounts[0].mountPath}")
PVC_NAME=$(kubectl get pvc -l $PVC_LABEL -o json | jq -r '.items[0].spec.volumeName')
PVC=$(kubectl get pvc -l $PVC_LABEL -o json | jq -r '.items[0].metadata.name')
VOLUME_ID=$(pxctl volume list | grep "$PVC_NAME" | awk '{print $1}')
```


We can see we have a volume with the size we asked for, and that storage available and mounted in the pod.
```execute
kubectl get pvc -l $PVC_LABEL
kubectl get pods -l $DEPLOY_LABEL
kubectl exec -it $POD -- df $VOL_MOUNT -h 
```

List all the volumes
```execute
pxctl volume list | grep -z $VOLUME_ID
```

Inspect the volume used by the deployment
```execute
pxctl volume inspect $VOLUME_ID
```

---

# Volume Expansion 

##### First notice that the current volume size is 2Gi

Resize the pvc
```execute
kubectl patch pvc $PVC --patch '{"spec":{"resources":{"requests":{"storage": "3Gi"}}}}'
```

List the volumes
```execute
pxctl volume list | grep -z $VOLUME_ID
```

We can see we have a volume with the size we asked for, and that storage available and mounted in the pod.
```execute
kubectl exec -it $POD -- df $VOL_MOUNT -h 
```

---

# AutoPilot Rule


Apply Auto Pilot rule
```execute
kubectl apply -f poc-test/dynamic-provision/autopilotrule.yaml
```

Write random bytes to files
```execute
kubectl -n portworx-poc exec deploy/nginx-pvc -- /bin/sh -c '{
  if [ -e /var/www/html/bigfile ]; then
    rm /var/www/html/bigfile
  fi
}'
kubectl -n portworx-poc exec -it deploy/nginx-pvc -- touch /var/www/html/bigfile
```

```execute
kubectl -n portworx-poc exec -it deploy/nginx-pvc -- sh -c "head -c 950M </dev/urandom > /var/www/html/bigfile"
```

```execute
kubectl -n portworx-poc exec -it deploy/nginx-pvc -- df -h /var/www/html
```

View the AutoPilot rule:
```editor:open-file
file: poc-test/dynamic-provision/autopilotrule.yaml
```

Wait for it to be triggerd
```execute
./poc-test/dynamic-provision/check_autopilot.sh
```

Show Autopilot events
```execute
kubectl get events --field-selector involvedObject.kind=AutopilotRule,involvedObject.name=nginx-pvc-volume-resize -A
```

<sup><strong>Note:</strong> May take up to 5 minutes /sup>

###### Check that size increased for pvc automaticly
```execute
kubectl -n portworx-poc get pvc
kubectl -n portworx-poc exec -it deploy/nginx-pvc -- df -h /var/www/html
```