# Gather ENV variables for pairing 
source "/home/eduk8s/poc-test/dr/cluster_pair/config-cls-pair.env"

# -------- S3 Secrets

kubectl config use-context $CLUSTER_EKS_1 > /dev/null 2>&1

# Get s3 credentials from secret
S3_ACCESS_KEY=$(kubectl get secret s3secret -n wordpress -o jsonpath='{.data.accessKeyID}' | base64 --decode)
S3_SECRET_KEY=$(kubectl get secret s3secret -n wordpress -o jsonpath='{.data.secretAccessKey}' | base64 --decode)


# -------- Portworx API

kubectl config use-context $CLUSTER_EKS_1 > /dev/null 2>&1

# Get API IP for both SRC and DEST clusters
SRC_PWX_API_EP=$(kubectl get svc -n $PX_NAMESPACE portworx-api -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

# Go to DEST cluster to get the IP
kubectl config use-context $CLUSTER_EKS_2 > /dev/null 2>&1

DST_PWX_API_EP=$(kubectl get svc -n $PX_NAMESPACE portworx-api -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')


# -------- Bucket Name

# Go back to SRC cluster
kubectl config use-context $CLUSTER_EKS_1 > /dev/null 2>&1

# Get the content of the bucket_name field from the s3-name-config ConfigMap in the default namespace
BUCKET_NAME=$(kubectl get cm s3-name-config -n default -o jsonpath='{.data.bucket_name}')


# -------- Cluster Pairing

echo -e "\nStart cluster pairing:"
echo -e "\nPX_NAMESPACE: $PX_NAMESPACE\n\
DST_PWX_API_EP: $DST_PWX_API_EP\n\
SRC_PWX_API_EP: $SRC_PWX_API_EP\n\
PROVIDER: $PROVIDER\n\
BUCKET_NAME: $BUCKET_NAME\n\
S3_ENDPOINT: $S3_ENDPOINT\n\
S3_ACCESS_KEY: $S3_ACCESS_KEY\n\
S3_SECRET_KEY: $S3_SECRET_KEY\n\
S3_REGION: $S3_REGION\n"

# Export the env
export PX_NAMESPACE="$PX_NAMESPACE"
export DST_PWX_API_EP="$DST_PWX_API_EP"
export SRC_PWX_API_EP="$SRC_PWX_API_EP"
export PROVIDER="$PROVIDER"
export BUCKET_NAME="$BUCKET_NAME"
export S3_ENDPOINT="$S3_ENDPOINT"
export S3_ACCESS_KEY="$S3_ACCESS_KEY"
export S3_SECRET_KEY="$S3_SECRET_KEY"
export S3_REGION="$S3_REGION"

# Copy kubeconfig files into the stork env pod
POD_NAME=$(kubectl get pods -n default -l app=stork-env -o jsonpath="{.items[0].metadata.name}")

kubectl cp ~/.kube/config-eks-1 -n default $POD_NAME:/ 
kubectl cp ~/.kube/config-eks-2 -n default $POD_NAME:/ 