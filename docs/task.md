# Assignment: Comprehensive Portworx Exercise

### Objective

Demonstrate various Portworx features by performing tasks related to dynamic provisioning, volume management, scalability, failure injection.

### Prerequisites

- A running Kubernetes cluster with [Portworx installed](./prerequisites.md).
  
  **Action**: 
  - namespace=kube-system
  - version=3.0

--

### Tasks

1. **Cluster-wide Encryption**  

    **Scenario**: Create [Cluster-Wide Secret](./readmes/volume-encryption.md) for Encryption Demonstration

    **Action**:
    - Create a cluster-wide secret to showcase the encryption capability of Portworx.
    - Create a secure [storage class](./snippets/encrypted-pvc/storage-class.yaml)

    **Expected Result**: A secure storage class that will be used as the storage class of Wordpress.

2. **Dynamically Provision Volumes**

   **Scenario**: Create a Wordpress application.

   **Action**: 
   - Use the secure StorageClass and create a WordPress application.
        To install:
        ```bash
        helm repo add bitnami https://charts.bitnami.com/bitnami && helm repo update
        helm upgrade -i wordpress bitnami/wordpress -n wordpress --create-namespace --set global.storageClass=<name-of-your-encrypted-storageclass>
        ```
   - Verify that the created PVC is dynamically provisioned.

   **Expected Result**: Dynamic provisioning of PVCs is functioning correctly. The PVC should be bound and the volume should be created.

3. **Shared Volume (ReadWriteMany)**

   **Scenario**: Mount the same volume in different PODs at the same time.

   **Action**:
   - Scale up the wordpress application to 4 pods.
   - Make sure the application keeps using the pvc even though 4 pods are using it.

   **Expected Result**: Data is written simultaneously from different pods.


### Scalability

1. **Grow a Volume**

   **Scenario**: Increase the volume size by [patching the PVC spec](./readmes/dynamic-provision.md).

   **Action**:
   - Edit the PVC used by WordPress to request more storage.
   - Verify that the volume has been resized.
   - Inspect the volume to see more information about it.
   - Make sure the file system of the pod also got resized (by using df -h).

   **Expected Result**: The volume size is increased without downtime.

2. **Automatically Grow a Volume**

   **Scenario**: Configure an [Autopilot](./readmes/dynamic-provision.md) rule to expand storage claims.

   **Action**:
   - Set up an Autopilot rule to automatically expand the WordPress PVC when storage usage reaches a certain threshold. 
   - Verify that volume capacity is increased according to set rules.

   **Expected Result**: The volume capacity increases automatically when the set threshold is reached.

3. **Scale up a Storage Pool**

   **Scenario**: Increase the pool size by adding disks.

   **Action**:
   - Add new disks to the Portworx storage pool.
   - Verify that the drives are added to the storage pool.

   **Expected Result**: The storage pool size increases as new disks are added.


4. **Scale out a Storage Cluster**

   **Scenario**: Add a new node to the storage cluster.

   **Action**:
   - Add a new node to the Portworx cluster.
   - Verify that PX automatically installs and increases total storage capacity.

   **Expected Result**: The new node is added and storage capacity is increased.

5. **Solution Lifecycle**

   **Scenario**: Upgrade the Portworx version in the cluster.

   **Action**:
   - Upgrade the Portworx version.
   - Verify that the upgrade was successful and no issues are detected for running applications.

   **Expected Result**: The Portworx version is upgraded successfully without any issues.



### Failure Injection

1. **Simulate Node Failure**

   **Scenario**: Take down a single storage node in the cluster.

   **Action**:
   - Inspect the volume of the application and identify the node its currently running on (use storkctl).
   - Simulate a [node failure](./readmes/HA.md) by shutting down the previously discorverd node that the application currently running on.
   - Verify that the WordPress DB restarts on a secondary node with all the data.
   - Inspect again the volume.

   **Expected Result**: The DB restarts on a secondary node without data loss.

2. **Application HA**

   **Scenario**: Delete a stateful pod.

   **Action**:
   - Delete the WordPress pods.
   - Verify that they are re-scheduled and remains alive.

   **Expected Result**: The WordPress pod is re-scheduled and remains functional.


---

### Conclusion

By the end of this task, you will have a comprehensive understanding of how to leverage Portworx features, including dynamic provisioning, scalability, failure handling, and monitoring. This hands-on experience will solidify your knowledge and skills in managing cloud-native storage solutions using Portworx.