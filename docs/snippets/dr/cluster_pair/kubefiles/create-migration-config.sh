#!/bin/bash

if [ "$#" -eq 0 ]
then
  echo "Please provide the role of the cluster as argument <src|dest>"
  exit 1
fi

if [ "$#" -ne 1 ]
then
  echo "Incorrect number of arguments"
  exit 1
fi

SERVICE_ACCOUNT=migration
ROLE=$1
CONTEXT=$(kubectl config current-context)
NAMESPACE="kube-system"
SERVER=$(kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[0].cluster.server}')

# Create a service account
kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ${SERVICE_ACCOUNT}
  namespace: ${NAMESPACE}
EOF

# Create a secret
kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: ${SERVICE_ACCOUNT}
  namespace: ${NAMESPACE}
  annotations:
    kubernetes.io/service-account.name: ${SERVICE_ACCOUNT}
type: kubernetes.io/service-account-token
EOF

# Create a RBAC
kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: migration-clusterrolebinding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: ${SERVICE_ACCOUNT}
  namespace: ${NAMESPACE}
EOF

SERVICE_ACCOUNT_TOKEN_COUNT=$(kubectl -n ${NAMESPACE} get secret -o=jsonpath='{.items[?(@.metadata.annotations.kubernetes\.io/service-account\.name=="'${SERVICE_ACCOUNT}'")].metadata.name}' | wc -w)
if [ ${SERVICE_ACCOUNT_TOKEN_COUNT} -gt 1 ]
then
  SERVICE_ACCOUNT_TOKEN_NAME=$(kubectl -n ${NAMESPACE} get secret -o=jsonpath='{.items[?(@.metadata.annotations.kubernetes\.io/service-account\.name=="'${SERVICE_ACCOUNT}'")].metadata.name}' | awk '{for(i=1;i<=NF;i++){ if($i ~ /-token/){print $i} } }' | head -n 1)
else
  SERVICE_ACCOUNT_TOKEN_NAME=$(kubectl -n ${NAMESPACE} get secret -o=jsonpath='{.items[?(@.metadata.annotations.kubernetes\.io/service-account\.name=="'${SERVICE_ACCOUNT}'")].metadata.name}')
fi
SERVICE_ACCOUNT_TOKEN=$(kubectl -n ${NAMESPACE} get secret ${SERVICE_ACCOUNT_TOKEN_NAME} -o "jsonpath={.data.token}" | base64 --decode)
SERVICE_ACCOUNT_CERTIFICATE=$(kubectl -n ${NAMESPACE} get secret ${SERVICE_ACCOUNT_TOKEN_NAME} -o "jsonpath={.data['ca\.crt']}")

cat <<EOF > "$ROLE-kubeconfig.yaml"
apiVersion: v1
kind: Config
clusters:
- name: ${CONTEXT}
  cluster:
    certificate-authority-data: ${SERVICE_ACCOUNT_CERTIFICATE}
    server: ${SERVER}
contexts:
- name: ${CONTEXT}
  context:
    cluster: ${CONTEXT}
    namespace: ${NAMESPACE}
    user: ${SERVICE_ACCOUNT}
current-context: ${CONTEXT}
users:
- name: ${SERVICE_ACCOUNT}
  user:
    token: ${SERVICE_ACCOUNT_TOKEN}
EOF