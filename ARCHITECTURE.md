# Architecture Overview

This document explains the architectural decisions behind the **Kubernetes Nginx Load Lab**.

The goal here is not to describe Kubernetes concepts in general, but to explain **why things were built this way**, what problems this design tries to solve, and what trade-offs were consciously accepted.

This is a lab by design. Clarity and learning value were prioritized over production-grade complexity.

---

## High-level architecture

At a high level, the lab consists of:

* A custom **Nginx-based Docker image**
* A **Deployment** running multiple replicas
* A **ConfigMap** controlling runtime behavior
* A **Service + Ingress** exposing the application
* An **HPA** reacting to real CPU usage
* **Minikube** as the Kubernetes environment

All components run locally and are intentionally kept minimal.

---

## Container architecture

### Single container, multiple responsibilities

Each pod runs **one container** that handles:

* Nginx (web server)
* Runtime environment discovery (hostname, IP, OS, versions)
* CPU load generation (when enabled)

This breaks the “one process per container” purist rule **on purpose**.

Why?

* The lab focuses on **pod-level behavior**
* HPA reacts to **real CPU usage inside the pod**
* Keeping everything in one container makes cause/effect very clear

This is a learning-oriented compromise.

---

### Startup flow

At container startup:

1. `start.sh` runs as PID 1
2. Environment data is collected (hostname, IP, versions)
3. Placeholders in `index.html` are replaced using `sed`
4. Nginx is started
5. A control loop begins, watching the ConfigMap flag

This guarantees that:

* The web page always reflects **actual runtime data**
* No rebuild or restart is needed to update load behavior

---

## Load generation design

### Why load generation lives inside the pod

Instead of using external tools or separate stress jobs, load generation is embedded directly in the application container.

Reasons:

* HPA decisions are based on **pod CPU metrics**
* Each pod becomes **self-contained**
* Scaling behavior is easier to reason about
* You can stress a single pod or all pods uniformly

From an SRE perspective, this makes system behavior more observable and predictable.

---

### ConfigMap-driven control

Load is controlled via a ConfigMap flag:

```
flag: "true" | "false"
```

Each pod periodically checks this value.

When `true`:

* CPU load is generated using `stress`
* Load is bounded in time to avoid runaway usage

When `false`:

* The pod returns to idle behavior

Key benefits:

* No pod restarts
* No image rebuilds
* Runtime behavior changes are immediate

This mirrors real-world configuration-driven systems.

---

## Kubernetes resources and their roles

### Deployment

* Manages replica count
* Ensures pod replacement on failure
* Provides the base for HPA scaling

Replica count is intentionally low at start to make scaling visible.

---

### Service

* Abstracts pod IPs
* Provides stable internal access
* Required for Ingress routing

A simple ClusterIP Service is sufficient here.

---

### Ingress

* Exposes the application via hostname
* Keeps networking realistic
* Avoids NodePort shortcuts

Ingress is preferred to simulate real cluster access patterns.

---

### HPA (Horizontal Pod Autoscaler)

* Scales based on CPU utilization
* Reacts to **real, internal load**
* Ties directly into the lab’s core objective

This is one of the main reasons load generation exists in the first place.

---

## Why Minikube

Minikube was chosen intentionally instead of managed Kubernetes:

* Full local control
* Easy reset and rebuild
* No abstraction hiding core behavior
* Zero cost

For learning and experimentation, this provides the fastest feedback loop.

---

## Things intentionally NOT included

Some features were consciously left out:

* Prometheus / Grafana
* Service Mesh
* External load generators
* Multiple containers per pod
* Advanced CI/CD pipelines

Why?

Because they would distract from the core learning goals.

The lab is meant to grow organically, not start complex.

---

## Trade-offs and known limitations

This architecture is **not meant for production**.

Known compromises:

* Multiple processes in one container
* Simple shell-based control loop
* CPU-focused load only
* Minimal error handling

These are acceptable in a lab context and help keep the system understandable.

---

## Evolution path

The current architecture allows future extensions such as:

* Multiple load profiles
* Memory-based scaling
* Per-pod load control
* External observability tooling
* Canary or blue/green deployments

The structure was designed to allow this evolution without major refactoring.

---

## Final note

This architecture prioritizes:

* Transparency over abstraction
* Behavior over theory
* Learning over perfection

Breaking things is expected.
Understanding why they broke is the real goal.