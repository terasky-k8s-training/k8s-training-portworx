#!/bin/bash


# Appply storage classes
CWD=$(dirname "$0")

kubectl apply -f "${CWD}/resources/portworx-sc-high-io.yaml"
kubectl apply -f "${CWD}/resources/portworx-sc-med-io.yaml"

# Set envs
SCENARIOS_NAMESPACE="pwx-poc-benchmark"
BENCHMARK_STORAGE_CLASSES=("portworx-sc-high-io" "ortworx-sc-med-io")

for sc in "${BENCHMARK_STORAGE_CLASSES[@]}" ; do
  echo "Starting benchmark for storage class ${sc}"
  helm install -n "${SCENARIOS_NAMESPACE}" --create-namespace "dbench-${sc}" "${CWD}/charts/dbench" \
              --set job.name="dbanch-${sc}-job" \
              --set namespace="${SCENARIOS_NAMESPACE}" \
              --set pvc.storageClassName="${sc}" \
              --set pvc.name="dbanch-${sc}-pvc" \
              -f ${CWD}/charts/dbench/values.yaml
  read -r -p "Press Enter to continue"
done
