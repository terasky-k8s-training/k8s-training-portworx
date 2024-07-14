# Portworx on EKS - Lab

In this lab, we will create an EKS cluster and install Portworx on it. We will perform different tasks, each representing a feature of Portworx. The features we will cover are:

- Application Deployment with PVC
- Volume Expansion
- Read Write Many
- Volume Encryption
- Backup
- High Availability
- Benchmarking

## Folder Structure

- **terraform**: Contains the specifications for creating an EKS cluster suited for Portworx installation. 
    Before creating the cluster, please alter the values file.

    To create the cluster, run:
    ```bash
    terraform init 
    terraform apply --auto-approve
    ```
    
    To access the cluster, run:
    ```bash
    aws eks update-kubeconfig --name <name_of_cluster> --region <region_of_cluster>
    ```

    To delete the cluster, run:
    ```bash
    terraform delete --auto-approve
    ```

- **docs**: Contains all the information you need to perform the tasks. [Link here](./docs)

## Links

- [Presentation Slide Show](https://docs.google.com/presentation/d/1SedcdKuFjbEjq9rVSihKq35ZrWZN5ojM/edit?usp=sharing&ouid=114711336959106187462&rtpof=true&sd=true)
- [Portworx Documentation](https://docs.portworx.com/poc)


## Course Completion
By the end of the course, you should be familiar with the topics in this document: [Acceptance Tests](https://terasky.atlassian.net/wiki/spaces/KAF/pages/150798338/Acceptance+tests)