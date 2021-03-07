Setting up a distributed Kubernetes cluster along with MacOS with Vagrant and VirtualBox
=

Architecture
-
I will create a Kubernetes 1.20.4 cluster with 3 nodes which contains the components below:

| IP           | Hostname | spec   | Componets              |
| ------------ | -------- | -------|----------------------- |
| 172.16.0.10  | master   | 2c, 2g |docker, kubelet, calico |
| 172.16.0.11  | node1    | 1c, 1g |docker, kubelet         |
| 172.16.0.12  | node2    | 1c, 1g |docker, kubelet         |
| 172.16.0.13  | node3    | 1c, 1g |docker, kubelet         |

```
kubeadm config view | grep Subnet
```

podSubnet: `192.168.0.0/16`   
serviceSubnet: `10.96.0.0/12`

Usage
-
### Spec

* MacBook Pro (15-inch, 2019), 6core, 16GB
* Vagrant 2.2.14
* VirtualBox 6.1.18
* Docker-ce-19.03.11
* Kubernetes 1.20.4

### Prerequisite
```
brew install --cask virtualbox
brew install --cask vagrant
brew install --cask vagrant-manager
```

### Install
````
vagrant up
````

### Mater Node
```
sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --apiserver-advertise-address=172.16.0.10

mkdir -p /home/vagrant/.kube
sudo cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
sudo chown $(id -u):$(id -g) /home/vagrant/.kube/config

kubectl apply -f https://docs.projectcalico.org/v3.15/manifests/calico.yaml
```
### Worker Node
```
kubeadm join 172.16.0.10:6443 --token <token> \
    --discovery-token-ca-cert-hash sha256:<hash>

mkdir -p /home/vagrant/.kube
sudo scp root@172.16.0.10:/etc/kubernetes/admin.conf /home/vagrant/.kube/config | echo "vagrant"
sudo chown $(id -u):$(id -g) /home/vagrant/.kube/config
```

### Validation
```
sudo cat /etc/kubernetes/manifests/kube-apiserver.yaml | grep service-cluster-ip-range
sudo cat /etc/cni/net.d/calico-kubeconfig
```

### TEST app
```
kubectl apply -f https://raw.githubusercontent.com/dasomel/paasta-contest/f3e06acabc8d4ebd8fdf5598a374f27741cf2aaa/sample-boot2/k8s/deployment.yaml
kubectl apply -f  https://raw.githubusercontent.com/dasomel/paasta-contest/f3e06acabc8d4ebd8fdf5598a374f27741cf2aaa/sample-boot2/k8s/service.yaml

http://172.16.0.10:30102/gradle/addSample.do
```