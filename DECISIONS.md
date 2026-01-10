# Architecture Decisions

This document records the main architectural decisions made during the development of the **Kubernetes Nginx Load Lab**.

It exists for one reason only:
to explain **why things are the way they are**.

This is not about proving that choices are perfect — it’s about making the reasoning explicit, so future changes are easier and more intentional.

---

## ADR-001 — Use Minikube instead of a managed Kubernetes cluster

**Decision**
Use Minikube as the Kubernetes environment.

**Reasoning**
The primary goal of this lab is learning and experimentation.

Minikube was chosen because it:

* Runs locally
* Is easy to destroy and recreate
* Exposes Kubernetes internals clearly
* Has zero cost

Using a managed cluster would hide too many details and slow down experimentation.

**Trade-offs**

* Not representative of production networking
* Limited scalability
* No multi-node realism by default

For this lab, those limitations are acceptable :)

---

## ADR-002 — Use Nginx as the application workload

**Decision**
Use Nginx instead of a custom application.

**Reasoning**
Nginx is stable, well-known, and predictable.

This removes application complexity from the equation and allows focusing on:

* Pod lifecycle
* Resource usage
* Scaling behavior
* Configuration changes

It also makes debugging easier, since Nginx behavior is widely understood.

**Trade-offs**

* Not representative of complex application stacks
* Limited business logic

This is intentional.

---

## ADR-003 — Generate load inside the application container

**Decision**
Embed CPU load generation logic inside the same container that runs Nginx.

**Reasoning**
This decision was made to keep cause and effect extremely clear.

* HPA reacts to pod-level CPU metrics
* Load generation affects the same pod that serves traffic
* Scaling behavior becomes easy to observe and reason about

External load generators were considered, but rejected to keep the feedback loop tight.

**Trade-offs**

* Multiple processes inside one container
* Not aligned with strict container best practices

For a lab, clarity beats purity.

---

## ADR-004 — Control load using a ConfigMap instead of environment variables

**Decision**
Use a ConfigMap flag to enable or disable load generation at runtime.

**Reasoning**
ConfigMaps allow behavior changes without restarting pods.

This mirrors real-world patterns where configuration changes should not:

* Rebuild images
* Redeploy workloads
* Restart healthy pods

It also enables dynamic experimentation during runtime.

**Trade-offs**

* Requires a polling loop inside the container
* Slight delay between change and effect

The benefits outweigh the complexity here.

---

## ADR-005 — Use a shell-based control loop (`start.sh`)

**Decision**
Implement startup and control logic using a shell script.

**Reasoning**
Shell scripts are:

* Transparent
* Easy to inspect
* Easy to modify during experiments

Using a full application or supervisor would add unnecessary abstraction.

**Trade-offs**

* Minimal error handling
* Less robustness than a proper process manager

Acceptable for a controlled lab environment.

---

## ADR-006 — Focus only on CPU-based HPA

**Decision**
Use CPU utilization as the only scaling metric.

**Reasoning**
CPU is the simplest and most observable signal for beginners.

It allows:

* Clear visualization of load
* Immediate HPA reactions
* Straightforward tuning

Memory-based or custom metrics were postponed intentionally.

**Trade-offs**

* Incomplete view of real-world scaling scenarios

This can be added later when the basics are well understood.

---

## ADR-007 — Avoid observability stacks initially

**Decision**
Do not include Prometheus, Grafana, or other observability tools initially.

**Reasoning**
The goal is to understand **Kubernetes behavior**, not monitoring stacks.

`kubectl top`, `kubectl describe hpa`, and direct observation are enough at this stage.

Adding observability too early would increase cognitive load.

**Trade-offs**

* Limited historical visibility
* No advanced metrics

These tools are planned for future iterations.

---

## ADR-008 — Prioritize clarity over production-readiness

**Decision**
Optimize the lab for readability, experimentation, and learning.

**Reasoning**
This repository is explicitly a lab.

Design choices were guided by questions like:

* “Is this easy to understand?”
* “Can I break this safely?”
* “Can I see what changed?”

Not by:

* High availability
* Security hardening
* Enterprise patterns

**Trade-offs**

* Not production-ready
* Some intentional shortcuts

This is by design :)

---

## Closing thoughts

These decisions are not final.

They represent the current stage of the lab and the learning goals at the time they were made.

As the lab evolves, new decisions will be added, and old ones may be revisited — and that’s exactly the point.