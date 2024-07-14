# Prerequisites

After creating a Kubernetes cluster we are ready to install portworx and the other cli tools.


#### Portworx installation

Access the [Portworx Central Site](https://central.portworx.com/landing/login)

After logining in, press "Get started"
![Get started](images/getstarted.png "Get started")

Select Portworx Enterprise
![Select License](images/licensing.png "Select License")

Design the Portworx cluster spec.
![Spec Generator](images/spec_generator.png "Spec Generator")

##### Cluster Inspect tools

Portworx cluster status:

```bash
pxctl status
```

mkdir -p /home/eduk8s/bin
cp /opt/workshop/poc-test/pxctl /home/eduk8s/bin/pxctl
chmod +x /home/eduk8s/bin/pxctl


Portworx cluster status:

```bash
storkctl status
```

PORTWORX_NS='kube-system'
STORK_POD=$(kubectl get pods -n  "$PORTWORX_NS" -l name=stork -o jsonpath='{.items[0].metadata.name}')
kubectl cp -n  "$PORTWORX_NS" $STORK_POD:/storkctl/linux/storkctl ./storkctl
mv ./storkctl /home/eduk8s/bin/storkctl
chmod +x /home/eduk8s/bin/storkctl
