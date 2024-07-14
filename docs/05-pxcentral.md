##### In this capability we will:
* Access PX-central UI.

--- 

```execute
kubectl config use-context $CLUSTER_EKS_1
clear
```

Check that the PX-central is ready
```execute
kubectl wait --for=condition=complete --timeout=7m -n px-central job/pxcentral-post-install-hook
```
<sup><strong>Note:</strong> Wait for it to be done.</sup>

##### Explore PX Central

```execute
INGRESS_HOST=$(kubectl get ingress -n px-central px-central-ui -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

echo "Access PX-Central at: http://$INGRESS_HOST/"
```

Login with the following credentials:

    Username: admin
    Password: admin / Aa123456

In the PX Central After login in, add a cluster

Gather Info about the cluster
```execute
CLUSTER_NAME=$(kubectl get stc -n kube-system -o json | jq -r '.items[0].metadata.name')
CLUSTER_ENDPOINT=$(kubectl get svc -n kube-system portworx-api -o json | jq -r '.spec.clusterIP')
```

Print it
```execute
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