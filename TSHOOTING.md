# Troubleshooting Guide

This document collects **realistic problems you are likely to hit while using this lab**, along with how to diagnose them and what you learn from each situation.

The goal is not to be exhaustive, but to document **failure patterns**.
Breaking things here is expected — that’s part of the lab :)

---

## Pods are running, but the page does not load

### Symptoms

* `kubectl get pods` shows all pods as `Running`
* Browser returns `ERR_CONNECTION_REFUSED` or times out
* `curl http://nginx.lab.local` fails

### What I checked

1. Verified Ingress:

   ```bash
   kubectl get ingress
   kubectl describe ingress
   ```

2. Checked `/etc/hosts`

   ```
   <minikube-ip> nginx.lab.local
   ```

3. Confirmed Minikube addons:

   ```bash
   minikube addons list
   ```

### Root cause

Ingress addon was not enabled.

### Fix

```bash
minikube addons enable ingress
```

### What I learned

Ingress objects are meaningless without a controller.
Kubernetes will happily accept the resource and do absolutely nothing with it :)

---

## HPA does not scale even with load enabled

### Symptoms

* Load flag is set to `true`
* Pods show CPU activity
* `kubectl get hpa` shows no scaling

### What I checked

```bash
kubectl top pods
kubectl get hpa
kubectl describe hpa
```

### Root cause

`metrics-server` was not running.

### Fix

```bash
minikube addons enable metrics-server
```

Wait a minute and re-check metrics.

### What I learned

HPA depends entirely on metrics availability.
No metrics = no scaling, no matter how much load you generate.

---

## ConfigMap changes do nothing

### Symptoms

* ConfigMap updated successfully
* No change in pod behavior
* Load never starts or stops

### What I checked

```bash
kubectl get configmap nginx-loadtest -o yaml
kubectl exec -it <pod> -- cat /path/to/flag/file
```

### Root cause

* Typo in the ConfigMap key
* Or the control loop was not running as expected

### Fix

* Verify exact key names
* Check container logs:

  ```bash
  kubectl logs <pod>
  ```

### What I learned

ConfigMaps are not magic.
Your application still needs to read them correctly and repeatedly.

---

## CPU spikes but HPA reacts very slowly

### Symptoms

* CPU usage jumps immediately
* HPA takes several minutes to scale

### Explanation

This is expected behavior.

HPA works with:

* Metrics collection intervals
* Stabilization windows
* Cooldown periods

### What I learned

HPA is intentionally conservative.
Fast reactions look nice in demos, but are dangerous in real systems.

Patience is part of the experiment :)

---

## One pod is overloaded while others are idle

### Symptoms

* One pod shows high CPU
* Others remain mostly idle

### Root cause

Load was triggered manually inside a single pod.

Example:

```bash
kubectl exec -it <pod> -- sh
```

### What I learned

This is actually a feature.

It shows that:

* HPA reacts to **average utilization**
* Kubernetes does not rebalance CPU magically
* Load locality matters

This is a great moment to reason about real production behavior.

---

## Nginx page shows wrong or empty runtime info

### Symptoms

* Hostname or IP missing
* Static placeholders visible

### Root cause

Startup script (`start.sh`) failed before completing template replacement.

### What I checked

```bash
kubectl logs <pod>
```

### Fix

* Validate shell script logic
* Add temporary `echo` statements
* Rebuild the image

### What I learned

When PID 1 fails silently, debugging gets painful fast.
Good logging is not optional, even in labs.

---

## General debugging tips

Things I usually do instinctively now:

* Keep one terminal running:

  ```bash
  watch kubectl get pods
  ```

* Another terminal for:

  ```bash
  kubectl top pods
  ```

* And one for logs:

  ```bash
  kubectl logs -f <pod>
  ```

This gives a near real-time mental model of what’s happening.

---

## Final note

If nothing breaks, you’re probably not experimenting hard enough :)

This document should grow over time — every weird behavior you investigate is worth writing down.