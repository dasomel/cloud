## [Helm]
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

## [Ingress]

# Adding the Helm Repository
helm repo add nginx-stable https://helm.nginx.com/stable
helm repo update

# Installing via Helm Repository
#helm install ingress nginx-stable/nginx-ingress
helm install nginx-ingress stable/nginx-ingress \
    --namespace $NAMESPACE \
    --set controller.replicaCount=1 \
    --set controller.nodeSelector."kubernetes\.io/hostname"=$LOADBALANCER_NODE \
    --set controller.service.loadBalancerIP="$LOADBALANCER_IP" \
    --set controller.extraArgs.default-ssl-certificate="$NAMESPACE/$LOADBALANCER_NODE-ssl"



## [Dashboard]
# https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml
