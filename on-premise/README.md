Installing on-premise Kubernetes
=

Cloud utility
-
* [docker-ce-desktop](https://www.docker.com/get-started)
> Docker Desktop is an application for MacOS and Windows machines for the building and sharing of containerized applications.
* [k9s](https://github.com/derailed/k9s)
> K9s provides a terminal UI to interact with your Kubernetes clusters.
* [dive](https://github.com/wagoodman/dive)
> A tool for exploring a docker image, layer contents, and discovering ways to shrink the size of your Docker/OCI image.
* [Helm](https://helm.sh)
> Helm The package manager for Kubernetes

***
* Windows
    - [cmder](https://cmder.net)
    > Cmder is a software package created out of pure frustration over the absence of nice console emulators on Windows.
    - [chocolatey](https://chocolatey.org)
    > The Package Manager for Windows

|install|shell|
|---|---|
|cmd.exe|`@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"`|
|powershell.exe|`Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))`|
* Mac
    - [brew](https://brew.sh)
> The Missing Package Manager for macOS (or Linux)

|OS|Install|
|---|---|
|mac|`/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"`|


Local install Kubernetes
-
# 0. Helm install
|OS|Install|
|---|---|
|windows|`choco install kubernetes-helm`|
|mac|`brew install helm`|

# 1. [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)
> An API object that manages external access to the services in a cluster, typically HTTP.   
Ingress may provide load balancing, SSL termination and name-based virtual hosting.
## Install
```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install ingress ingress-nginx/ingress-nginx
```

# 2. [Gitea](gitea.io/)
> Gitea - Git with a cup of tea   
A painless self-hosted Git service.
## Install
```bash
helm repo add gitea-charts https://dl.gitea.io/charts/

kubectl apply -f ./gitea/gitea-pvc.yaml
* Need to modify file storage path

helm install gitea --set persistence.existingClaim=gitea-pvc \
                        ,ingress.enabled=true \
                        ,ingress.hosts[0]='hostname' \
                        ,gitea.admin.password='password' \
                         gitea-charts/gitea
```
## Access
### Modify hosts file   
localIP hostname   
e.g.) 10.10.10.10 www.example.com

|OS|hosts file path|
|---|---|
|windows|`C:\Windows\System32\drivers\etc`|
|mac|`/etc/hosts`|

### username(default): gitea_admin
### Log error correction   
>│ gitea @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  
│ gitea @         WARNING: UNPROTECTED PRIVATE KEY FILE!          @  
│ gitea @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  
│ gitea Permissions 0755 for '/data/ssh/ssh_host_rsa_key' are too open.  
│ gitea It is required that your private key files are NOT accessible by others.  
│ gitea This private key will be ignored.  
│ gitea Unable to load host key "/data/ssh/ssh_host_rsa_key": bad permissions  
│ gitea Unable to load host key: /data/ssh/ssh_host_rsa_key  
```bash
chmod 600 ~/.ssh/your-key.pem
```

# 3. [Harbor](https://goharbor.io)
> Our mission is to be the trusted cloud native repository for Kubernetes
## Install
```bash
helm repo add harbor https://helm.goharbor.io

helm install harbor --set harborAdminPassword='password' \
                         ,ingress.enabled=true \
                          bitnami/harbor
```
## Access
### Modify hosts file   
localIP hostname   
e.g.) 10.10.10.10 core.harbor.domain

|OS|hosts file path|
|---|---|
|windows|`C:\Windows\System32\drivers\etc`|
|mac|`/etc/hosts`|
### username(default): admin
   
# 4. [Jenkins](https://www.jenkins.io)
> The leading open source automation server, Jenkins provides hundreds of plugins to support building, deploying and automating any project.
## Install
```bash
kubectl apply -f ./jenkins/jenkins-pvc.yaml
* Need to modify file storage path

kubectl apply -f .\jenkins\deployment.yaml
kubectl apply -f .\jenkins\service.yaml
```

# 5. [Nexus](https://www.sonatype.com/nexus/repository-oss)
> The free artifact repository with universal format support.
## Install
```bash
helm repo add oteemocharts https://oteemo.github.io/charts
helm install nexus --set nexus.service.type=NodePort \
                         oteemocharts/sonatype-nexus
```

# 6. [MariaDB](https://mariadb.org)
> The open source relational database
## Install
```bash
kubectl apply -f ./mariadb/mariadb-pvc.yaml
* Need to modify file storage path

helm install mariadb --set auth.rootPassword='password' \
                          ,primary.persistence.existingClaim=mariadb-pvc \
                          ,primary.service.type=NodePort \
                          ,primary.service.nodePort=31000 \
                           bitnami/mariadb
* Nodeport range: 30000-32767
```

# 7. [PostgreSQL](https://www.postgresql.org)
> The World's Most Advanced Open Source Relational Database
## Install
```bash
helm install postgresql --set postgresqlUsername=root \
                             ,postgresqlPassword='password' \
                             ,service.type=NodePort \
                             ,service.nodePort=31001 \
                             ,image.debug=true \
                              bitnami/postgresql
* Nodeport range: 30000-32767
```

# 8. [kafka](https://kafka.apache.org)
> Apache Kafka is an open-source distributed event streaming platform used by thousands of companies for high-performance data pipelines, streaming analytics, data integration, and mission-critical applications.
## Install
```bash
helm install kafka --set externalAccess.enabled=true \
                        ,externalAccess.service.type=NodePort \
                        ,externalAccess.service.nodePorts={31002} \
                        ,externalZookeeper.servers='local IP' \
                         bitnami/kafka
* Nodeport range: 30000-32767
```

# 9. [Redis](https://redis.io)
> Redis is an open source (BSD licensed), in-memory data structure store, used as a database, cache and message broker.
## Install
```bash
helm install redis --set master.service.type=NodePort \
                        ,master.service.nodePort=31004 \
                        ,slave.service.type=NodePort \
                        ,slave.service.nodePort=31005 \
                         bitnami/redis
* Nodeport range: 30000-32767
```

## Access
### Confirm password
```bash
kubectl get secret --namespace default redis -o jsonpath="{.data.redis-password}" | base64 --decode
```

# 10. [mongoDB](https://www.mongodb.com)
> MongoDB is a general purpose, document-based, distributed database built for modern application developers and for the cloud era.
## Install
```bash
helm install mongodb --set auth.rootPassword='password' \
                          ,service.type=NodePort \
                          ,service.nodePort=31006 \
                           bitnami/mongodb
* Nodeport range: 30000-32767
```  

# 11. [Argo Workflows](https://argoproj.github.io/argo/)
> The workflow engine for Kubernetes
## Install
```bash
kubectl create ns argo
kubectl apply -n argo -f https://raw.githubusercontent.com/argoproj/argo/stable/manifests/install.yaml
kubectl -n argo port-forward deployment/argo-server 2746:2746
``` 

# 12. [Argo CD](https://argoproj.github.io/argo-cd/)
> GitOps continuous delivery tool for Kubernetes.
## Install
```bash
kubectl create ns argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

## Access
### Confirm password
```bash
kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2
```

# 13. [Tekton Pipelines](https://github.com/tektoncd/pipeline)
> The Tekton Pipelines project provides k8s-style resources for declaring CI/CD-style pipelines.
## Install
```bash
kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml

kubectl apply -f ./tekton/tekton-pvc.yaml
* Need to modify file storage path
```

# 14. [Kubernetes Dashboard](https://github.com/kubernetes/dashboard)
> Kubernetes Dashboard is a general purpose, web-based UI for Kubernetes clusters. It allows users to manage applications running in the cluster and troubleshoot them, as well as manage the cluster itself.

## Install
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.4/aio/deploy/recommended.yaml
```
## Access
```bash
kubectl proxy

http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/.
```

### Confirm token
```bash
kubectl get secrets
kubectl describe secrets default-token-xxxxx
```
