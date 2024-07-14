# Dynamic Provision & Volume Expansion & AutoPilot

#### In this capability we will:
- Dynamic Provision: Show Portworx most basic ability - Attach a pvc to a pod.
- Volume Expansion: Show Portworx ability to expend the size of pvc without downtime.
- AutoPilot: Create a rule to automatically expand PVCs when they have low available space.

---

## Dynamic Provision

Apply the [storage class](../snippets/dynamic-provision/storage-class.yaml):
```bash
kubectl apply -f snippets/dynamic-provision/storage-class.yaml
```

Create the [deployment](../snippets/dynamic-provision/deployment.yaml) and [pvc](../snippets/dynamic-provision/pvc.yaml):
```bash
kubectl apply -f ../snippets/dynamic-provision/pvc.yaml 
kubectl apply -f ../snippets/dynamic-provision/deployment.yaml
```

Save application labels
```bash
DEPLOY_LABEL='app=nginx-pvc'
PVC_LABEL='app=nginx-pvc'
```

Check that the deployment is ready
```bash
kubectl wait --for=condition=Ready pod -l $DEPLOY_LABEL --timeout 5m
```
<sup><strong>Note:</strong> Wait for the deployment to be ready</sup>

Gather the information about the application
```bash
POD=$(kubectl get po -l $DEPLOY_LABEL -o name | head -1)
VOL_MOUNT=$(kubectl get $POD -o jsonpath="{.spec.containers[0].volumeMounts[0].mountPath}")
PVC_NAME=$(kubectl get pvc -l $PVC_LABEL -o json | jq -r '.items[0].spec.volumeName')
PVC=$(kubectl get pvc -l $PVC_LABEL -o json | jq -r '.items[0].metadata.name')
VOLUME_ID=$(pxctl volume list | grep "$PVC_NAME" | awk '{print $1}')
```

We can see we have a volume with the size we asked for, and that storage available and mounted in the pod.
```bash
kubectl get pvc -l $PVC_LABEL
kubectl get pods -l $DEPLOY_LABEL
kubectl exec -it $POD -- df $VOL_MOUNT -h 
```

##### To inspect the volume with pxctl:

List all the volumes
```bash
pxctl volume list | grep -z $VOLUME_ID
```

Inspect the volume used by the deployment
```bash
pxctl volume inspect $VOLUME_ID
```

---

## Volume Expansion 

#### First notice that the current volume size is 2Gi

Resize the pvc
```bash
kubectl patch pvc $PVC --patch '{"spec":{"resources":{"requests":{"storage": "3Gi"}}}}'
```

List the volumes
```bash
pxctl volume list | grep -z $VOLUME_ID
```

We can see we have a volume with the size we asked for, and that storage available and mounted in the pod.
```bash
kubectl exec -it $POD -- df $VOL_MOUNT -h 
```

---

## AutoPilot Rule

Before running the following commands inspect the autopilot rule [here](../snippets/dynamic-provision/autopilotrule.yaml)
Notice that the rule is desgined to increase the size of the volume to 5G if 30% of the space is used.

---

Write random bytes to files to decrease the available space on the volume
```bash
kubectl -n portworx-poc exec deploy/nginx-pvc -- /bin/sh -c '{
  if [ -e /var/www/html/bigfile ]; then
    rm /var/www/html/bigfile
  fi
}'
kubectl -n portworx-poc exec -it deploy/nginx-pvc -- touch /var/www/html/bigfile
kubectl -n portworx-poc exec -it deploy/nginx-pvc -- sh -c "head -c 950M </dev/urandom > /var/www/html/bigfile"
kubectl -n portworx-poc exec -it deploy/nginx-pvc -- df -h /var/www/html
```

Apply [Auto Pilot rule](../snippets/dynamic-provision/autopilotrule.yaml)
```bash
kubectl apply -f ../snippets/dynamic-provision/autopilotrule.yaml
```

To know if it worked you can check the events to see if the action was successfull, and then inspect again the pvc.

Show Autopilot events
```bash
kubectl get events --field-selector involvedObject.kind=AutopilotRule,involvedObject.name=nginx-pvc-volume-resize -A
```
<sup><strong>Note:</strong> May take up to 5 minutes </sup>


###### Check that size increased for pvc automaticly
```bash
kubectl -n portworx-poc get pvc
kubectl -n portworx-poc exec -it deploy/nginx-pvc -- df -h /var/www/html
```