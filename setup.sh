#!/bin/bash

cd manifest/bootstrap
oc apply -f openshift-gitops-operator.yaml

echo -n "Waiting for OpenShift GitOps operator being ready.."
while true; do
  echo -n "."
  oc wait --for jsonpath='{.status.phase}'=Succeeded --timeout 10m csv/$(oc get subs/openshift-gitops-operator -o jsonpath='{.status.currentCSV}' -n openshift-gitops-operator 2>/dev/null) -n openshift-gitops-operator 2>/dev/null | grep "condition met"
  if [ $? -eq 0 ]; then
    break
  fi
  sleep 3
done

echo ""

oc apply -f secret-repo-creds.yaml
oc apply -f v4-0-config-user-idp-0-file-data.yaml
oc apply -f applicationset.yaml

sleep 180
MAX_USERS=${1:-5}
for (( i=1; i<=${MAX_USERS}; i++ ))
do
  RESOURCE_NAME="user${i}"
  if ! oc get project "${RESOURCE_NAME}" &> /dev/null; then
    oc new-project "${RESOURCE_NAME}"
  fi
  oc label namespace "${RESOURCE_NAME}" opendatahub.io/dashboard='true'
  oc adm policy add-role-to-user admin "${RESOURCE_NAME}" -n "${RESOURCE_NAME}"
  oc adm policy add-role-to-user admin "${RESOURCE_NAME}" -n llm-serving
  oc adm policy add-scc-to-user -z default anyuid -n "${RESOURCE_NAME}"
  sleep 3
  oc apply -f minio.yaml
  oc apply -f dataconnection.yaml
  oc apply -f openwebui.yaml 
done

machineset="$(oc get machineset -o jsonpath='{.items[0].metadata.name}' -n openshift-machine-api)"
machineset_gpu="${machineset}-gpu"

while true; do
  echo -n "."
  if ! oc get machineset/${machineset_gpu} -n openshift-machine-api &> /dev/null; then
    sleep 20
  else
    break
  fi
done

oc scale machineset/${machineset_gpu} --replicas ${MAX_USERS} -n openshift-machine-api
#oc apply -f acceleratorprofile.yaml
TARGET_STATUS="llm-serving Synced Healthy nvidia-gpu-operator Synced Healthy oauth OutOfSync Healthy openshift-gitops Synced Healthy openshift-nfd Synced Healthy redhat-ods-applications Synced Healthy redhat-ods-operator Synced Healthy"

echo ""
echo "!!! If you can't get enough g6.xlarge instance, this setup script won't finish. !!!"
echo "!!! If it doesn't finish after more than an hour, run 'oc get machine -A'   !!!"
echo "!!! to check if the instance is being provisioned.                          !!!"
echo ""
echo -n "Waiting for the environment being ready. it may take 30-40 minutes.."
while true; do
  echo -n "."
  status="$(echo $(oc get application.argoproj.io --no-headers -n openshift-gitops 2>/dev/null))"
  if [ "${status}" == "${TARGET_STATUS}" ]; then
    break
  fi
  sleep 10
done

echo ""
echo "The environment is ready."

echo ""
echo ""

echo "[OpenShift AI Console URL]"
echo "https://$(oc get route/rhods-dashboard -o jsonpath='{.spec.host}' -n redhat-ods-applications)/"
echo ""

echo ""
