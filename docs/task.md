# Assignment: Comprehensive Portworx Exercise

### Objective

Demonstrate various Portworx features by performing tasks related to dynamic provisioning, volume management, scalability, failure injection.

### Prerequisites

- A running Kubernetes cluster with [Portworx installed](./prerequisites.md).
  
  **Action**: 
  - Namespace: kube-system
  - Version: 3.0

---

### Tasks

1. **Cluster-wide Encryption**  

    **Scenario**: Create [Cluster-Wide Secret](./readmes/volume-encryption.md) for Encryption Demonstration
   
    **Action**:
    - Create a cluster-wide secret to showcase the encryption capability of Portworx.
    - Create a secure [storage class](./snippets/encrypted-pvc/storage-class.yaml)
         - allowVolumeExpansion: true
         - repl: 2
         - secure: true

    **Expected Result**: A secure storage class that will be used as the storage class of Wordpress.


2. **Dynamically Provision Volumes**

   **Scenario**: Create a Wordpress application.

   **Action**: 
   - Use the secure StorageClass and create a WordPress application.
        To install:
        ```bash
        helm repo add bitnami https://charts.bitnami.com/bitnami && helm repo update
        helm upgrade -i wordpress bitnami/wordpress -n wordpress --create-namespace --set global.storageClass=<name-of-your-encrypted-portworx-storageclass>
        ```
   - Verify that the created PVC is dynamically provisioned and the application is starting and you can access it.

   **Expected Result**: Dynamic provisioning of PVCs is functioning correctly. The PVC should be bound and the application is working.


3. **Shared Volume (ReadWriteMany)**

   **Scenario**: Mount the same volume in different PODs at the same time.

   **Action**:
   - Scale up the wordpress application to 2 pods.
   - Make sure the application keeps using the pvc even though multiple pods are using it.
   - Upload a post by accessing /admin, example [here](./readmes/backup.md)

   **Expected Result**: Data is written simultaneously from different pods.


### Scalability

1. **Grow a Volume**

   **Scenario**: Increase the volume size by [patching the PVC spec](./readmes/dynamic-provision.md).

   **Action**:
   - Patch the PVC used by WordPress to request more storage.
        - Name: data-wordpress-mariadb-0
        - Size: 8Gi --> 10Gi
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


3. **Solution Lifecycle**

   **Scenario**: Upgrade the Portworx version in the cluster.

   **Action**:
   - [Upgrade the Portworx version](https://docs.portworx.com/poc/Maintenance_Upgrade-Portworx).
        - Version: 3.1.2
        - Namespace: kube-system
   - Verify that the upgrade was successful and no issues are detected for running applications.
   - Make sure the Wordpress application and data are not harmed.

   **Expected Result**: The Portworx version is upgraded successfully without any issues.

### Backup

1. **Application Backup**

   **Scenario**: [Backup the Wordpress application to an s3](./readmes/backup.md).

   **Action**:
   - If you didn't already, upload a post.
   - Create all the resources neccessary for backuping application to s3.
   - Backup the application - Track the upload and then inspect the s3.
   - Delete completely the wordpress application and reinstall it.
        - ```bash
          helm delete wordpress -n wordpress
          kubectl delete pvc -n wordpress data-wordpress-mariadb-0
          ```
    - Restore the application and wait for it to be ready.
    - Look for your post

   **Expected Result**: All the data should be saved even after deleting the entire application.


### UI 

1. **Install PX Cenral and PX Backup**

   **Scenario**: [Install and explore PX Central and PX Backup](./readmes/pxcentral.md).

   **Action**:
   - Install the UI.
   - Explore and preform some tasks.
   - In the **lighthouse** fill out your cluster details
   <!-- - Add a new cluster:
        - Cloud Account Name: your name
        - Access Key: Run again `terraform output`
        - Secret Key: Run `terraform output s3_user_access_key_secret`
        - Region: your region
    Select and add your cluster -->

   **Expected Result**: Explore the capabilities offered by PX-Central and PX-Backup.


### Failure Injection

1. **Simulate Node Failure**

   **Scenario**: Take down a single storage node in the cluster.

   **Action**:
   - Inspect the volume of the application and identify the node its currently running on (use pxctl).
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