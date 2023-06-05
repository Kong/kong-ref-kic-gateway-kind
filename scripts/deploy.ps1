# Create Kind Cluster
kind create cluster --config .\kind\kind-config.yaml
$env:KUBECONFIG = $env:USERPROFILE + "\.kube\config"
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.0/manifests/calico.yaml
kubectl -n kube-system set env daemonset/calico-node FELIX_IGNORELOOSERPF=true

# K8s resources, prometheus, grafana, and statsd
kubectl create namespace monitoring
kubectl create namespace kong
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install -f .\monitoring\prometheus-values.yaml prometheus prometheus-community/kube-prometheus-stack -n monitoring --wait
helm install -f .\monitoring\statsd-values.yaml statsd prometheus-community/prometheus-statsd-exporter -n monitoring --wait
helm install redis bitnami/redis -n kong --set auth.enabled=false --set replica.replicaCount=0

# Create Keys and Certs, Namespace, and Load into K8s
openssl rand -out .rnd
openssl req -new -x509 -sha256 -nodes -newkey -keyout .\cluster.key -out .\cluster.crt -days 1095 -subj "/CN=kong_clustering"
kubectl create secret tls kong-cluster-cert --cert=.\cluster.crt --key=.\cluster.key -n kong

# Load License
kubectl create secret generic kong-enterprise-license -n kong --from-file=license=$env:KONG_LICENSE

# Create Manager Config
New-Item "admin_gui_session_conf" -Force
$manager_config = @"
{
    "cookie_name":"admin_session",
    "cookie_samesite":"off",
    "secret":"kong",
    "cookie_secure":false,
    "storage":"kong"
}
"@
Add-Content "admin_gui_session_conf" $manager_config
kubectl create secret generic kong-session-config -n kong --from-file=admin_gui_session_conf

# Create Portal Config
New-Item "portal_gui_session_conf" -Force
$portal_config = @"
{
    "cookie_name":"portal_session",
    "cookie_samesite":"off",
    "secret":"kong",
    "cookie_secure":false,
    "cookie_domain":"localhost",
    "storage":"kong"
}
"@
Add-Content "portal_gui_session_conf" $portal_config
kubectl create secret generic kong-session-config -n kong --from-file=portal_gui_session_conf

# Add Kong Helm Repo
helm repo add kong https://charts.konghq.com
helm repo update

# Deploy Kong Control Plane
kubectl create secret generic kong-enterprise-superuser-password --from-literal=password=password -n kong
helm install --version 2.20.2 -f .\helm-values\cp-values.yaml kong kong/kong -n kong --set env.audit_log=off --set manager.ingress.hostname=localhost --set admin.ingress.hostname=localhost --set portalapi.ingress.hostname=localhost --wait

# Deploy Kong Data Plane
kubectl create namespace kong-dp
kubectl create secret tls kong-cluster-cert --cert=./cluster.crt --key=./cluster.key -n kong-dp
kubectl create secret generic kong-enterprise-license -n kong-dp --from-file=license=$env:KONG_LICENSE
helm install --version 2.20.2 -f .\helm-values\dp-values.yaml kong-dp kong/kong -n kong-dp --set proxy.ingress.hostname=localhost --wait

# Deploy sample app httpbin
kubectl apply -f ./sample-app/httpbin.yaml
