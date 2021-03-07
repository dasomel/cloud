# Install bash-completion
source /usr/share/bash-completion/bash_completion

# Enable kubectl autocompletion
echo 'source <(kubectl completion bash)' >>~/.bashrc

# alias for kubectl
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -F __start_kubectl k' >>~/.bashrc
exit

# (Mater Node)
#sudo kubeadm init --pod-network-cidr=10.0.0.0/16 --service-cidr=10.96.0.0/16 --apiserver-advertise-address=172.16.0.10
sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --apiserver-advertise-address=172.16.0.10

mkdir -p /home/vagrant/.kube
sudo cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
sudo chown $(id -u):$(id -g) /home/vagrant/.kube/config

# Install Calico networking and network policy for on-premises deployments
#kubectl create -f https://docs.projectcalico.org/manifests/calico.yaml

#curl -O https://docs.projectcalico.org/v3.15/manifests/calico.yaml
#sed -i 's/# - name: CALICO_IPV4POOL_CIDR/- name: CALICO_IPV4POOL_CIDR/' calico.yaml
#sed -i 's/#   value: "192.168.0.0/  value: "10.0.0.0/' calico.yaml
#kubectl apply -f calico.yaml

kubectl apply -f https://docs.projectcalico.org/v3.15/manifests/calico.yaml

# (Worker Node)
mkdir -p /home/vagrant/.kube
sudo scp root@172.16.0.10:/etc/kubernetes/admin.conf /home/vagrant/.kube/config | echo "vagrant"
sudo chown $(id -u):$(id -g) /home/vagrant/.kube/config


kubeadm join 172.16.0.10:6443 --token cwxlxx.jtgyqpccaiyrmz9z \
    --discovery-token-ca-cert-hash sha256:63535ac91e4da14866d280941a54553b11b6d25d791e03d08c186da6b11fdaad

# validation
sudo cat /etc/kubernetes/manifests/kube-apiserver.yaml | grep service-cluster-ip-range
sudo cat /etc/cni/net.d/calico-kubeconfig

# TEST app
kubectl apply -f https://raw.githubusercontent.com/dasomel/paasta-contest/f3e06acabc8d4ebd8fdf5598a374f27741cf2aaa/sample-boot2/k8s/deployment.yaml
kubectl apply -f  https://raw.githubusercontent.com/dasomel/paasta-contest/f3e06acabc8d4ebd8fdf5598a374f27741cf2aaa/sample-boot2/k8s/service.yaml

http://172.16.0.10:30102/gradle/addSample.do