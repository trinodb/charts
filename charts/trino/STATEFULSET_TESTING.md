# StatefulSet Testing Guide

This guide shows how to test and verify the StatefulSet deployment for Trino.

## Prerequisites

```bash
# Ensure you have kubectl and helm installed
kubectl version --client
helm version

# Ensure you have a Kubernetes cluster running (minikube, kind, or cloud cluster)
kubectl cluster-info
```

## Option 1: Deployment Mode (Default)

### Preview the configuration
```bash
cd /Users/hpopuri/Nrprojects/trino-helm-chart/charts/trino

# Preview what will be created (Deployment mode - default)
helm template my-trino . | grep -E "^(kind:|  name:)"
```

### Install with Deployment mode
```bash
# Install the chart
helm install my-trino . \
  --namespace trino \
  --create-namespace

# Check the resources created
kubectl get all -n trino

# Check pod names
kubectl get pods -n trino

# Expected pod names in Deployment mode have random suffixes:
# my-trino-trino-coordinator-7b5f4c8d9-xk2lm
# my-trino-trino-worker-6c9d8f7b5-abc12
# my-trino-trino-worker-6c9d8f7b5-def34
```

### Verify configuration
```bash
# Check coordinator deployment
kubectl describe deployment my-trino-trino-coordinator -n trino

# Check worker deployment
kubectl describe deployment my-trino-trino-worker -n trino

# Check logs
kubectl logs -n trino deployment/my-trino-trino-coordinator

# Cleanup
helm uninstall my-trino -n trino
```

---

## Option 2: StatefulSet Mode with Persistent Storage

### Preview the StatefulSet configuration
```bash
# Preview StatefulSet for workers with persistent storage
helm template my-trino . \
  --set worker.statefulset.enabled=true \
  --set 'worker.statefulset.volumeClaimTemplates[0].metadata.name=data' \
  --set 'worker.statefulset.volumeClaimTemplates[0].mountPath=/data/trino' \
  --set 'worker.statefulset.volumeClaimTemplates[0].spec.accessModes[0]=ReadWriteOnce' \
  --set 'worker.statefulset.volumeClaimTemplates[0].spec.storageClassName=standard' \
  --set 'worker.statefulset.volumeClaimTemplates[0].spec.resources.requests.storage=1Gi' \
  | grep -E "^(kind:|  name:)"
```

### Install with StatefulSet mode (Workers only)
```bash
# Install with StatefulSet for workers
helm install my-trino . \
  --namespace trino \
  --create-namespace \
  --set worker.statefulset.enabled=true \
  --set 'worker.statefulset.volumeClaimTemplates[0].metadata.name=data' \
  --set 'worker.statefulset.volumeClaimTemplates[0].mountPath=/data/trino' \
  --set 'worker.statefulset.volumeClaimTemplates[0].spec.accessModes[0]=ReadWriteOnce' \
  --set 'worker.statefulset.volumeClaimTemplates[0].spec.storageClassName=standard' \
  --set 'worker.statefulset.volumeClaimTemplates[0].spec.resources.requests.storage=1Gi'

# Check the resources created
kubectl get all -n trino

# Check pod names
kubectl get pods -n trino

# Expected pod names in StatefulSet mode:
# my-trino-trino-coordinator-7b5f4c8d9-xk2lm  - Deployment with random suffix
# my-trino-trino-worker-0                      - StatefulSet with ordinal index
# my-trino-trino-worker-1                      - StatefulSet with ordinal index
```

### Verify StatefulSet and PVCs
```bash
# Check StatefulSet
kubectl get statefulset my-trino-trino-worker -n trino
kubectl describe statefulset my-trino-trino-worker -n trino

# Check PersistentVolumeClaims (one per pod)
kubectl get pvc -n trino

# Expected PVC names will be:
#   data-my-trino-trino-worker-0
#   data-my-trino-trino-worker-1

# Check PVC details
kubectl describe pvc data-my-trino-trino-worker-0 -n trino

# Check volume mounts inside a worker pod
kubectl exec -n trino my-trino-trino-worker-0 -- df -h | grep trino

# Check logs
kubectl logs -n trino my-trino-trino-worker-0
```

### Test pod stability (StatefulSet feature)
```bash
# Delete a worker pod - it will be recreated with the same name
kubectl delete pod my-trino-trino-worker-0 -n trino

# Watch it recreate with the same name
kubectl get pods -n trino -w

# The pod will come back as my-trino-trino-worker-0 with the same name
# And it will reattach to the same PVC data-my-trino-trino-worker-0
```

---

## Option 3: Full StatefulSet Mode (Coordinator + Workers)

### Create a custom values file
```bash
cat > statefulset-values.yaml <<EOF
coordinator:
  statefulset:
    enabled: true
    podManagementPolicy: OrderedReady
    volumeClaimTemplates:
      - metadata:
          name: data
        mountPath: /data/trino
        spec:
          accessModes:
            - ReadWriteOnce
          storageClassName: standard
          resources:
            requests:
              storage: 5Gi
      - metadata:
          name: logs
        mountPath: /var/log/trino
        spec:
          accessModes:
            - ReadWriteOnce
          storageClassName: standard
          resources:
            requests:
              storage: 2Gi

worker:
  statefulset:
    enabled: true
    podManagementPolicy: Parallel
    volumeClaimTemplates:
      - metadata:
          name: data
        mountPath: /data/trino
        spec:
          accessModes:
            - ReadWriteOnce
          storageClassName: standard
          resources:
            requests:
              storage: 10Gi
      - metadata:
          name: logs
        mountPath: /var/log/trino
        spec:
          accessModes:
            - ReadWriteOnce
          storageClassName: standard
          resources:
            requests:
              storage: 5Gi
      - metadata:
          name: cache
        mountPath: /var/cache/trino
        spec:
          accessModes:
            - ReadWriteOnce
          storageClassName: standard
          resources:
            requests:
              storage: 20Gi

server:
  workers: 3
EOF
```

### Install with the custom values file
```bash
# Preview
helm template my-trino . -f statefulset-values.yaml | grep -E "^(kind:|  name:)"

# Install
helm install my-trino . \
  --namespace trino \
  --create-namespace \
  -f statefulset-values.yaml

# Check all resources
kubectl get all,pvc -n trino

# Expected resources will include:
#
# StatefulSets:
#   my-trino-trino-coordinator - 1 replica
#   my-trino-trino-worker - 3 replicas
#
# Pods:
#   my-trino-trino-coordinator-0
#   my-trino-trino-worker-0
#   my-trino-trino-worker-1
#   my-trino-trino-worker-2
#
# PVCs - 2 per coordinator plus 3 per worker:
#   data-my-trino-trino-coordinator-0
#   logs-my-trino-trino-coordinator-0
#   data-my-trino-trino-worker-0
#   logs-my-trino-trino-worker-0
#   cache-my-trino-trino-worker-0
#   data-my-trino-trino-worker-1
#   logs-my-trino-trino-worker-1
#   cache-my-trino-trino-worker-1
#   data-my-trino-trino-worker-2
#   logs-my-trino-trino-worker-2
#   cache-my-trino-trino-worker-2
```

### Verify persistent storage
```bash
# Check all PVCs
kubectl get pvc -n trino

# Check volume mounts in coordinator
kubectl exec -n trino my-trino-trino-coordinator-0 -- df -h

# Check volume mounts in worker
kubectl exec -n trino my-trino-trino-worker-0 -- df -h

# Write test data to persistent volume
kubectl exec -n trino my-trino-trino-worker-0 -- sh -c "echo 'test data' > /data/trino/test.txt"

# Delete the pod
kubectl delete pod my-trino-trino-worker-0 -n trino

# Wait for it to recreate
sleep 30

# Verify the data persists
kubectl exec -n trino my-trino-trino-worker-0 -- cat /data/trino/test.txt
# Should output: test data
```

---

## Option 4: Testing with Minikube

### Start minikube with adequate resources
```bash
# Start minikube
minikube start --cpus=4 --memory=8192 --disk-size=50g

# Enable default storage class
minikube addons enable default-storageclass
minikube addons enable storage-provisioner

# Verify storage class exists
kubectl get storageclass
```

### Install and test
```bash
# Install with StatefulSet mode
helm install my-trino . \
  --namespace trino \
  --create-namespace \
  -f statefulset-values.yaml

# Watch pods come up
kubectl get pods -n trino -w

# Check services
kubectl get svc -n trino

# Port forward to access Trino UI
kubectl port-forward -n trino svc/my-trino-trino 8080:8080

# Open browser to http://localhost:8080
```

---

## Verification Commands

### Check pod naming convention
```bash
# Deployment mode: random suffix
# <release-name>-trino-coordinator-<random-hash>-<random-id>
# <release-name>-trino-worker-<random-hash>-<random-id>

# StatefulSet mode: ordinal index
# <release-name>-trino-coordinator-<ordinal>
# <release-name>-trino-worker-<ordinal>

kubectl get pods -n trino -o wide
```

### Check unique FQDN per pod - StatefulSet feature
```bash
# Each StatefulSet pod gets a unique DNS name in the format:
# pod-name.service-name.namespace.svc.cluster.local

# From another pod, resolve the DNS names
kubectl run -it --rm debug --image=busybox --restart=Never -- nslookup my-trino-trino-worker-0.my-trino-trino-worker.trino.svc.cluster.local

# This is useful for Istio STRICT mTLS
```

### Check StatefulSet rolling updates
```bash
# Update worker image
helm upgrade my-trino . \
  --namespace trino \
  -f statefulset-values.yaml \
  --set image.tag=478

# Watch the rolling update - ordered for coordinator, parallel for workers
kubectl get pods -n trino -w

# Check rollout status
kubectl rollout status statefulset/my-trino-trino-worker -n trino
```

### Compare Deployment vs StatefulSet behavior
```bash
# With Deployment - Pod deletion creates new pod with NEW name
kubectl get pods -n trino
kubectl delete pod <deployment-pod-name> -n trino
kubectl get pods -n trino
# New pod will have a different random suffix

# With StatefulSet - Pod deletion recreates with SAME name
kubectl get pods -n trino
kubectl delete pod my-trino-trino-worker-0 -n trino
kubectl get pods -n trino
# New pod will have the same name my-trino-trino-worker-0
```

---

## Cleanup

```bash
# Uninstall the release
helm uninstall my-trino -n trino

# Delete PVCs - they persist after uninstall by default
kubectl delete pvc --all -n trino

# Delete namespace
kubectl delete namespace trino

# Stop minikube if using it
minikube stop
```

---

## Troubleshooting

### PVCs stuck in pending
```bash
# Check storage class
kubectl get storageclass

# Check PVC status
kubectl describe pvc -n trino

# If using minikube ensure storage provisioner is enabled
minikube addons list | grep storage
```

### Pods not starting
```bash
# Check pod events
kubectl describe pod <pod-name> -n trino

# Check logs
kubectl logs <pod-name> -n trino

# Check resource availability
kubectl top nodes
kubectl top pods -n trino
```

### Template rendering errors
```bash
# Validate template syntax
helm template my-trino . --debug

# Validate with specific values
helm template my-trino . -f statefulset-values.yaml --debug
```