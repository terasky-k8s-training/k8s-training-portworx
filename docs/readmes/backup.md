# Backup

##### In this capability we will:
* backup an application (its resources and data). 
* Back them up in a S3.
* Delete the application and restore it.

--- 


Inspect the previously created Wordpress environment
```bash
kubectl get pods,pvc -n wordpress
```
<sup><strong>Note:</strong> Make sure the Wordpress environment is ready</sup>

-----

Create backup location configuration
```bash
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

Create a [backup location](../snippets/backup/backuplocation.yaml) in a s3
```bash
kubectl apply -f poc-test/backup/backuplocation.yaml
storkctl get backuplocation -n wordpress
```

Start the [backup](../snippets/backup/applicationbackup.yaml) to the S3
```bash
kubectl apply -f poc-test/backup/applicationbackup.yaml
watch storkctl get applicationbackup -n wordpress
```
<sup><strong>Note:</strong> Wait for applicationbackup to finish!</sup>

-----

Delete the Wordpress environment
```bash
helm delete wordpress -n wordpress
kubectl delete pvc -n wordpress data-wordpress-mariadb-0
```

Inspect the deleted environment
```bash
kubectl get pods,pvc -n wordpress
```

Restore the Wordpress environment, by applying the [applicationrestore](../snippets/backup/applicationrestore.yaml)
```bash
kubectl apply -f poc-test/backup/applicationrestore.yaml
watch storkctl get applicationrestore -n wordpress
```
<sup><strong>Note:</strong> Wait for applicationrestore to finish!</sup>


##### Check and see that the Wordpress environment was restored!

```bash
kubectl get pods,pvc -n wordpress
```
