# Benchmarking

##### In this capability we will:
* Create a storage class with high IO. 
* Run a pod and install on it dbench.
* Attach to the pod a pvc that will be bound to the storage class.
* Run and inspect IO test.

--- 

Create the [storage class](../snippets/benchmark/resources/portworx-sc-high-io.yaml)
```bash
kubectl apply -f poc-test/benchmark/resources/portworx-sc-high-io.yaml
```
On this storage class we will preform the IO tests.


Install the helm chart
```bash
helm install -n pwx-poc-benchmark --create-namespace "dbench-portworx-sc-high-io" "poc-test/benchmark/charts/dbench" \
    --set job.name="dbanch-portworx-sc-high-io-job" \
    --set namespace="pwx-poc-benchmark" \
    --set pvc.storageClassName="portworx-sc-high-io" \
    --set pvc.name="dbanch-portworx-sc-high-io-pvc" \
    -f poc-test/benchmark/charts/dbench/values.yaml
```

With this chart we have done the following:
1. Create a pvc that will be attached to the previously created storage class.
2. Create a pod that will mound the pvc.
3. Run preformance check.


##### Inspect the preformance 

```bash
kubectl wait --for=condition=complete --timeout=5m -n pwx-poc-benchmark job/dbanch-portworx-sc-high-io-job
```
<sup><strong>Note:</strong> Takes a few momenets before all the tests are done</sup>

```bash
DBENCH_POD=$(kubectl -n pwx-poc-benchmark get pods -l job-name=dbanch-portworx-sc-high-io-job -o=jsonpath='{.items[*].metadata.name}')
kubectl -n pwx-poc-benchmark logs ${DBENCH_POD}
```

