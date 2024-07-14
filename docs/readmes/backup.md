# Backup

##### In this capability we will:
* Create a Wordpress Application
* Upload a post to see that the data is actully saved
* Backup the application (its resources and data) to a s3. 
* Delete the application and restore it.
* See that the post still exists

--- 

## Prerequisites
- A wordpress application.

  To install the wordpress application run:

  ```bash
  helm repo add bitnami https://charts.bitnami.com/bitnami && helm repo update
  helm upgrade -i wordpress bitnami/wordpress -n wordpress --create-namespace --set global.storageClass=px-db
  ```

---

Inspect the Wordpress application
```bash
kubectl get pods,pvc -n wordpress
```
<sup><strong>Note:</strong> Make sure the Wordpress environment is ready</sup>

Now before starting the backup proccess we will first log in to the wordpress application and upload a post.

To Access the UI
```bash
SERVICE_IP=$(kubectl get ingress wordpress -n wordpress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "
Details:

WordPress URL: http://$SERVICE_IP/
WordPress Admin URL: http://$SERVICE_IP/wp-admin

Credentials:
Username: user
Password: $(kubectl get secret --namespace wordpress wordpress -o jsonpath="{.data.wordpress-password}" | base64 -d)
"
```

Access the Admin URL login with the credentials and upload a post.


## Start Backup to S3

Create a [secret](../snippets/backup/s3secret.yaml) with access info about the s3
```bash
kubectl apply -f ../snippets/backup/backuplocation.yaml
```

Create a [backup location](../snippets/backup/backuplocation.yaml) in the s3
```bash
kubectl apply -f ../snippets/backup/backuplocation.yaml
storkctl get backuplocation -n wordpress
```

Start the [application backup](../snippets/backup/applicationbackup.yaml) to the S3
```bash
kubectl apply -f ../snippets/backup/applicationbackup.yaml
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
kubectl apply -f ../snippets/backup/applicationrestore.yaml
watch storkctl get applicationrestore -n wordpress
```
<sup><strong>Note:</strong> Wait for applicationrestore to finish!</sup>


##### Check and see that the Wordpress environment was restored!

```bash
kubectl get pods,pvc -n wordpress
```
