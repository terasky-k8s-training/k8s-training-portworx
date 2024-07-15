# Command Cheat Sheet

## pxctl Commands

- **pxctl status**
  - Shows the current status of the Portworx cluster.
  ```bash
  pxctl status
  ```

- **pxctl volume list**
  - Lists all volumes managed by Portworx.
  ```bash
  pxctl volume list
  ```

- **pxctl volume inspect $VOLUME_ID**
  - Inspects the details of a specific volume.
  ```bash
  pxctl volume inspect $VOLUME_ID
  ```

---

## kubectl Commands

- **kubectl get stc**
  - Gets the storage cluster managed by Portworx.
  ```bash
  kubectl get stc
  ```

- **kubectl get storageclass**
  - Gets all storage classes, including those by Portworx.
  ```bash
  kubectl get storageclass
  ```

---

## storkctl Commands

- **storkctl get backuplocation**
  - Gets backup locations configured for Stork.
  ```bash
  storkctl get backuplocation
  ```
  
- **storkctl get applicationbackup**
  - Gets application backups managed by Stork.
  ```bash
  storkctl get applicationbackup
  ```

- **storkctl get applicationrestore**
  - Gets application restores managed by Stork.
  ```bash
  storkctl get applicationrestore
  ```