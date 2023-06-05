# Configure Environment Variables
$env:KUBECONFIG = $env:USERPROFILE + "\.kube\config"
$env:KONG_PROXY_PORT = 30000
$env:KONG_PROXY_HOSTNAME = "localhost"
$env:KONG_SERVICE_HOSTNAME = $env:KONG_PROXY_HOSTNAME
$env:KONG_PROXY_URI = $env:KONG_PROXY_HOSTNAME + ":" + $env:KONG_PROXY_PORT
$env:KONG_SERVICE_URI = $env:KONG_PROXY_HOSTNAME + ":" + $env:KONG_PROXY_PORT
$env:KONG_PROXY_URL = "http://" + $env:KONG_PROXY_URI
$env:KONG_SERVICE_URL = "http://" + $env:KONG_SERVICE_URI

$env:KONG_ADMIN_API_PORT = 30001
$env:KONG_ADMIN_API_HOSTNAME = "localhost"
$env:KONG_ADMIN_API_URI = $env:KONG_ADMIN_API_HOSTNAME + ":" + $env:KONG_ADMIN_API_PORT
$env:KONG_ADMIN_API_URL = "http://" + $env:KONG_ADMIN_API_URI

$env:KONG_MANAGER_PORT = 30002
$env:KONG_MANAGER_HOSTNAME = "localhost"
$env:KONG_MANAGER_URI = $env:KONG_MANAGER_HOSTNAME + ":" + $env:KONG_MANAGER_PORT
$env:KONG_MANAGER_URL = "http://" + $env:KONG_MANAGER_URI

$env:KONG_PORTAL_GUI_PORT = 30003
$env:KONG_PORTAL_GUI_HOST = "localhost"
$env:KONG_PORTAL_GUI_URI = $env:KONG_PORTAL_GUI_HOST + ":" + $env:KONG_PORTAL_GUI_PORT
$env:KONG_PORTAL_GUI_URL = "http://" + $env:KONG_PORTAL_GUI_URI

$env:KONG_PORTAL_API_PORT = 30004
$env:KONG_PORTAL_API_HOSTNAME = "localhost"
$env:KONG_PORTAL_API_URI = $env:KONG_PORTAL_API_HOSTNAME + ":" + $env:KONG_PORTAL_API_PORT
$env:KONG_PORTAL_API_URL = "http://" + $env:KONG_PORTAL_API_URI

# Keycloak for External IDP OIDC Plugin exercises
$env:KEYCLOAK_PORT = 8080
$env:KEYCLOAK_HOSTNAME = "localhost"
$env:KEYCLOAK_URI = $env:KEYCLOAK_HOSTNAME + ":" + $env:KEYCLOAK_PORT
$env:KEYCLOAK_URL = "http://" + $env:KEYCLOAK_URI
$env:KEYCLOAK_CONFIG_ISSUER = "http://" + $env:KEYCLOAK_URI + "/auth/realms/kong/.well-known/openid-configuration"
$env:CLIENT_SECRET = "681d81ee-9ff0-438a-8eca-e9a4f892a96b"
$env:KEYCLOAK_REDIRECT_URI = $env:KONG_SERVICE_URI
$env:KEYCLOAK_REDIRECT_URL = $env:KONG_SERVICE_URL

# Prometheus for K8s Control Plane and Kong Analytics
$env:PROMETHEUS_PORT = 30006
$env:PROMETHEUS_HOSTNAME = "localhost"
$env:PROMETHEUS_URI = $env:PROMETHEUS_HOSTNAME + ":" + $env:PROMETHEUS_PORT
$env:PROMETHEUS_URL = "http://" + $env:PROMETHEUS_URI

# Grafana for K8s Control Plane and Kong Analytics
$env:GRAFANA_PORT = 30005
$env:GRAFANA_HOSTNAME = "localhost"
$env:GRAFANA_URI = $env:GRAFANA_HOSTNAME + ":" + $env:GRAFANA_PORT
$env:GRAFANA_URL = "http://" + $env:GRAFANA_URI

# Teardown
.\scripts\teardown.ps1

# Deploy
.\scripts\deploy.ps1

# Deploy Keycloak IDP Container
Set-Location .\keycloak-idp
docker-compose up -d
Set-Location ..

Write-Host ""
Write-Host "KONG GATEWAY API PROXY URL: " $env:KONG_PROXY_URL
Write-Host "KONG ADMIN API URL: " $env:KONG_ADMIN_API_URL
Write-Host "KONG MANAGER URL: " $env:KONG_MANAGER_URL
Write-Host "KONG PORTAL URL: " $env:KONG_PORTAL_GUI_URL
Write-Host "Keycloak URL: " $env:KEYCLOAK_URL
Write-Host "Prometheus URL: " $env:PROMETHEUS_URL
Write-Host "Grafana URL: " $env:GRAFANA_URL
Write-Host ""
