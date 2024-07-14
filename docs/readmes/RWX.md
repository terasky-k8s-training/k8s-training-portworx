# Read Write Many

##### Create a PVC with the ReadWriteMany (RWX) capabilty.
RWX is the ability to share a volume with multiple pods running on different nodes!
For this, we need to create an appropriate StorageClass and specifiy the RWX accessMode in the PVC

--- 

```bash
kubectl config use-context $CLUSTER_TKG
clear
```

Create and View the Storage Class:
```editor:open-file
file: poc-test/rwx/storage-class.yaml
```


View the pvc and the deployment
```editor:open-file
file: poc-test/rwx/pvc.yaml
```

```editor:open-file
file: poc-test/rwx/deployment.yaml
```

Create the storageclass
```bash
kubectl apply -f poc-test/rwx/storage-class.yaml
kubectl get sc px-sc-repl-rwx
```

Create deployment and pvc:
```bash
kubectl apply -f poc-test/rwx/pvc.yaml 
kubectl apply -f poc-test/rwx/deployment.yaml 2>/dev/null
```

Save labels
```bash
DEPLOY_LABEL='app=nginx-pvc-rwx'
PVC_LABEL='app=nginx-pvc-rwx'
```

Check that the deployment is ready
```bash
kubectl wait --for=condition=Ready pod -l $DEPLOY_LABEL --timeout 5m
```
<sup><strong>Note:</strong> Wait for the deployment to be ready</sup>


Gather the information about the application
```bash
PVC_NAME=$(kubectl get pvc -l $PVC_LABEL -o json | jq -r '.items[0].spec.volumeName')
VOLUME_ID=$(pxctl volume list | grep "$PVC_NAME" | awk '{print $1}')
POD1=$(kubectl get po -l $DEPLOY_LABEL -o name | head -1)
POD2=$(kubectl get po -l $DEPLOY_LABEL -o name | grep -v $POD1 )
VOL_MOUNT=$(kubectl get  $POD1 -o jsonpath="{.spec.containers[0].volumeMounts[0].mountPath}")
```

List the volumes
```bash
pxctl volume list | grep -z $VOLUME_ID
```


Inspect the volume
```bash
pxctl volume inspect $VOLUME_ID
```

---

##### To test this capability:
* We will create a file from both pods,
* Then list the dircetory in both pods to see if the files are there for each of them.

Create file from pod 1
```bash
kubectl exec -it $POD1 -- touch $VOL_MOUNT/hello-from-pod1
```

Create file from pod 2
```bash
kubectl exec -it $POD2 -- touch $VOL_MOUNT/pod2-say-hello
```

List files from pod 1
```bash
kubectl exec -it $POD1 -- ls -lA $VOL_MOUNT
```

List files from pod 2
```bash
kubectl exec -it $POD2 -- ls -lA $VOL_MOUNT
```

###### As you can see all files exists from both pods 