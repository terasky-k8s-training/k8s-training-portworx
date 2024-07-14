##### In this capability we will:
* backup an application (its resources and data). 
* Back them up in a S3.
* Delete the application and restore it.

--- 

```execute
kubectl config use-context $CLUSTER_EKS_1
clear
```

Inspect the previously created Wordpress environment
```execute
kubectl get pods,pvc -n wordpress
```
<sup><strong>Note:</strong> Make sure the Wordpress environment is ready</sup>

-----

Create backup location configuration
```execute
BUCKET_NAME=$(kubectl get cm s3-name-config -n default -o jsonpath='{.data.bucket_name}')

cat <<EOF
apiVersion: stork.libopenstorage.org/v1alpha1
kind: BackupLocation
metadata:
  name: wordpress-backup
  namespace: wordpress
  annotations:
    stork.libopenstorage.org/skipresource: "true"
location:
  type: s3
  path: "$BUCKET_NAME"
  secretConfig: s3secret
  sync: true 
EOF > poc-test/backup/backuplocation.yaml
```

Inspect the configuration files for the backup

```editor:open-file
file: poc-test/backup/backuplocation.yaml
```

```editor:open-file
file: poc-test/backup/applicationbackup.yaml
```

```editor:open-file
file: poc-test/backup/applicationrestore.yaml
```

Create a backup location in a s3
```execute
kubectl apply -f poc-test/backup/backuplocation.yaml
storkctl get backuplocation -n wordpress
```

Start the backup to the S3
```execute
kubectl apply -f poc-test/backup/applicationbackup.yaml
watch storkctl get applicationbackup -n wordpress
```
<sup><strong>Note:</strong> Wait for applicationbackup to finish!</sup>

-----

Delete the Wordpress environment
```execute
helm delete wordpress -n wordpress
kubectl delete pvc -n wordpress data-wordpress-mariadb-0
```

Inspect the deleted environment
```execute
kubectl get pods,pvc -n wordpress
```

Restore the Wordpress environment
```execute
kubectl apply -f poc-test/backup/applicationrestore.yaml
watch storkctl get applicationrestore -n wordpress
```
<sup><strong>Note:</strong> Wait for applicationrestore to finish!</sup>


##### Check and see that the Wordpress environment was restored!

```execute
kubectl get pods,pvc -n wordpress
```
