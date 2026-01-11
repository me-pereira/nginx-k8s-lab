# 🧪 Kubernetes Nginx Load Lab

This repository is a **hands-on Kubernetes lab** built with **Minikube**, **Docker**, and **Nginx**.

I created this lab mainly as a safe place to experiment. Instead of learning concepts in isolation, the idea here is to see things happening: CPU usage going up, pods scaling, traffic flowing, and configuration changes taking effect in real time.

It started small, but it’s intentionally structured so it can **evolve over time** :)

---

## 🎯 Why this lab exists

While studying Kubernetes and SRE topics, I noticed that many examples:

* Are either too simple (no real behavior change)
* Or too complex (too many tools at once)

Here I tried to find a **middle ground**.

This lab helps you:

* Understand how **Nginx behaves inside Kubernetes**
* Control **CPU load dynamically**, without restarting pods
* Learn how **ConfigMaps can change application behavior**
* See **HPA decisions** based on real metrics
* Validate everything visually through a simple web page

I deliberately avoided cloud providers and external dependencies to keep the **feedback loop fast** and **cost-free** ;)

---

## 🧠 Design decisions (and why)

Some choices here are very intentional.

### 🟢 Why Minikube?

Because it:

* Is easy to reset
* Runs locally
* Forces you to understand Kubernetes without hiding things
* Deals with Control Plane configuration, so you can focus on testing other aspects

For learning purposes, this beats managed clusters.

---

### 🌐 Why Nginx?

Nginx is:

* Simple
* Well known
* Stable
* Easy to expose via Service and Ingress

That lets you focus on **Kubernetes behavior**, not app complexity.

---

### 🔥 Why generate load inside the pod?

I could have used:

* External load generators
* Separate stress pods
* Jobs or CronJobs

Instead, I chose to **embed load generation logic inside the same container**.

* HPA reacts to pod-level metrics
* Each pod becomes self-contained
* Scaling behavior is easier to reason about
* You can access a specific pod and activate stress only there

This also makes the lab more realistic from an SRE point of view.

---

## 🗂️ Repository structure

```
.
├── docker/
│   ├── Dockerfile
│   ├── start.sh
│   └── static_site/
│       └── index.html
│
├── kubernetes/
│   ├── configmap.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   └── hpa.yaml
│
└── README.md
```

Why this split?

* Everything related to the image lives in `docker/`
* Everything Kubernetes-related lives in `kubernetes/`

This separation makes the project easier to grow and refactor over time.

---

## 📦 Requirements (only what is needed)

I avoided listing optional tools here on purpose.

### 🐳 Docker

Used to build images and to run Minikube.

```bash
sudo apt update
sudo apt install -y docker.io
sudo usermod -aG docker $USER
newgrp docker
```

Check Docker before moving on:

```bash
docker version
```

---

### ☸️ kubectl

Kubernetes CLI.

```bash
sudo snap install kubectl --classic
```

---

### 🚀 Minikube

Local Kubernetes cluster.

```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

Start with Docker driver:

```bash
minikube start --driver=docker
```

Enable required addons:

```bash
minikube addons enable metrics-server
minikube addons enable ingress
```

Validate:

```bash
kubectl get nodes
kubectl get pods -n kube-system
```

---

## 🛠️ Building the Docker image

From the project root:

```bash
docker build -t eberlin/nginx-lab:1.0.2 ./docker
```

I used a custom image instead of plain `nginx` because:

* I needed `stress`
* I wanted full control over startup behavior

This decision makes HPA testing much more realistic :D

---

## 📡 Deploying to Kubernetes

Apply manifests explicitly:

```bash
kubectl apply -f kubernetes/configmap.yaml
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml
kubectl apply -f kubernetes/ingress.yaml
kubectl apply -f kubernetes/hpa.yaml
```

I prefer this order because:

* ConfigMaps should exist before pods
* HPA only makes sense once metrics are flowing

---

## 🌍 Accessing the application

Get Minikube IP:

```bash
minikube ip
```

Add it to `/etc/hosts`:

```
<minikube-ip> nginx.lab.local
```

Open:

```
http://nginx.lab.local
```

---

## ⚙️ Load testing control

Load generation is controlled via a **ConfigMap flag**.

Enable load:

```bash
kubectl patch configmap nginx-loadtest -p '{"data":{"flag":"true"}}'
```

Disable load:

```bash
kubectl patch configmap nginx-loadtest -p '{"data":{"flag":"false"}}'
```

Why ConfigMap?

* Dynamic behavior change
* No pod restarts
* Very close to real production patterns

Each pod checks the flag and reacts independently.

---

### 💡 Suggestion: use shell aliases

Typing full patch commands gets old quickly.

I strongly suggest adding aliases:

```bash
alias load-on="kubectl patch configmap nginx-loadtest -p '{"data":{"flag":"true"}}'"
alias load-off="kubectl patch configmap nginx-loadtest -p '{"data":{"flag":"false"}}'"
```

This makes experimentation faster and more natural during testing ;)

---

## 📊 Observing behavior

CPU usage per pod:

```bash
kubectl top pods
```

HPA status:

```bash
kubectl get hpa
kubectl describe hpa
```

Watch scaling:

```bash
watch kubectl get pods
```

I usually keep one terminal just watching pods scale up and down.

---

## 🔧 Useful commands

Access a pod shell:

```bash
kubectl exec -it <pod-name> -- sh
```

Quick HTTP loop:

```bash
for i in {1..10}; do curl http://nginx.lab.local; done
```

---

## 🚧 Possible future improvements

Some ideas intentionally left out:

* Multiple load profiles
* Memory-based HPA
* Prometheus and Grafana
* Canary deployments
* Fault injection

The idea is to evolve this lab gradually, not turn it into a full platform.

---

📄 Additional Documentation

This repository also includes supplementary Markdown files to provide deeper insights and guidance:

ARCHITECTURE.md – Details the system architecture, container responsibilities, and load generation design.

DECISIONS.md – Explains design choices, trade-offs, and why certain approaches were taken.

TROUBLESHOOTING.md – Contains common issues, debugging tips, and practical solutions encountered during lab setup.

These files help you understand the lab’s structure, reasoning, and how to handle potential problems.

---

## 👤 Author

mepereira
GitHub: [https://github.com/me-pereira](https://github.com/me-pereira)
LinkedIn: [https://linkedin.com/in/marcel-eberlin](https://linkedin.com/in/marcel-eberlin)

### 🤖 Documentation note

I used ChatGPT to **refine wording**, **improve structure** and **add visual clarity** (icons and organization) to this documentation.

All technical decisions, architecture, review, and implementation details were designed, tested, and validated manually as part of the project growth process.

---

To whoever uses it: **this is a lab**.
It is meant to be modified, broken, and improved over time. Feel free to use it as much as you like :)
