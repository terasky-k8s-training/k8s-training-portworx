# Assignment

---

## Objective
The objective of this assignment is to demonstrate various capabilities of Kubernetes and Portworx, including encryption, read-write operations, Autopilot policy creation, benchmarking, and backup and restore procedures.

---

## Tasks
1.  ##### Create Cluster-Wide Secret for Encryption Demonstration
    Create a cluster-wide secret to showcase the encryption capability of Portworx.

2.  ##### Create Two Deployments
    One deployment will read data from the encrypted persistent volume claim (PVC).
    Another deployment will write data to the encrypted PVC.
    This task aims to demonstrate the read-write capability of the system.

    * deployment 1: deploy-read
    * deployment 2: deploy-write
    * pvc: pvc-poc
    * namespace: portworx-poc

3.  ##### Create an Autopilot Policy.
    Create an Autopilot policy that triggers expansion when the PVC consumption reaches 80%. To verify the functionality:

    Generate a file that gradually consumes storage space.

    ```execute
    head -c 550M </dev/urandom > /var/www/html/bigfile
    ```

    Monitor the PVC and file system growth.
    ```execute
    watch kubectl get events --field-selector involvedObject.kind=AutopilotRule,involvedObject.name=ap-rule-poc -A
    ```

    This task will demonstrate the Autopilot feature's ability to dynamically scale storage.

    * autopilot rule: ap-rule-poc
    * pvc: pvc-poc
    * namespace: portworx-poc

4.  ##### Backup and Restore Procedure
    Backup the application data, delete the PVC, and restore it. This step will test the backup and restore functionality.

    <sup><strong>Note:</strong> Use the existing s3 - use the s3secret to access it.</sup>

