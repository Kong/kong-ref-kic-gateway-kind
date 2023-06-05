$env:KUBECONFIG = $env:USERPROFILE + "\.kube\config"

# Delete kind cluster
kind delete cluster --name multiverse

# Bring down docker containers
Set-Location ./keycloak-idp
docker-compose down
Set-Location ../
