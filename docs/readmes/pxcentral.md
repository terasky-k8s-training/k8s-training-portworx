## PX-Central/PX-Backup

##### In this capability we will:
* Install PX-central, PX-backup UI.
* Access them.

--- 

#### Installation

Install PX-central and PX-backup
```bash
helm repo add portworx http://charts.portworx.io/ && helm repo update
helm install px-central portworx/px-central --namespace px-central --create-namespace --version 2.6.0 --set persistentStorage.enabled=true,persistentStorage.storageClassName="px-db",pxbackup.enabled=true
```

Expose the px-central and px-backup service
```bash
kubectl apply -f poc-test/px-central/ingress.yaml
```

Check that the PX-central is ready
```bash
kubectl wait --for=condition=complete --timeout=7m -n px-central job/pxcentral-post-install-hook
```
<sup><strong>Note:</strong> Wait for it to be done.</sup>


##### Explore PX Central and PX Backup

```bash
PXCENTRAL_INGRESS_HOST=$(kubectl get ingress -n px-central px-central-ui -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "Access PX-Central at: http://$PXCENTRAL_INGRESS_HOST/"
```

Login with the following credentials:
- Username: admin
- Password: admin

In PX Central After login in, add a cluster

Gather Info about the cluster
```bash
CLUSTER_NAME=$(kubectl get stc -n kube-system -o json | jq -r '.items[0].metadata.name')
CLUSTER_ENDPOINT=$(kubectl get svc -n kube-system portworx-api -o json | jq -r '.spec.clusterIP')

echo "
Cluster Name: $CLUSTER_NAME
Cluster Endpoint: $CLUSTER_ENDPOINT
"
```

Fill out the form with the given information and add the cluster.

---

Now you can inspect the cluster.

Abilitys:
1. Inspect the cluster info
2. Inspect the workers, storage classes and pvc's  
3. Edit existing pvc's - Their size and HA option
4. Create new schedule policys
5. Create credentials to access Cloud