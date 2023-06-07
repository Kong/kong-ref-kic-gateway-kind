#!/usr/bin/env bash

# Check for Dependencies
echo "Checking for Dependencies..."

# Check for python3
if ! command -v python3 &> /dev/null
then
    echo "python3 not found"
    return
fi

# Check commands
ANYMISSING=0
for dependency in kind openssl docker docker-compose kubectl helm
do
    if ! command -v $dependency &> /dev/null
    then
        echo "$dependency $(python3 -c "print(\"\u274c\")")"
        ANYMISSING=1
    else
        echo "$dependency $(python3 -c "print(\"✓\")")"
    fi
done

if [ $ANYMISSING -eq 1 ]
then
    echo "Dependencies not found. Please install and add to path and rerun."
    return
fi

# Check $KONG_LICENSE
if [[ -z "${KONG_LICENSE}" ]]; then
    echo "The environment variable KONG_LICENSE needs to be defined."
    return
fi
if [ ! -f $KONG_LICENSE ]; then
    echo "$KONG_LICENSE does not exist."
    return
fi

# Check $KONG_HOSTNAME
if [[ -z "${KONG_HOSTNAME}" ]] | [[ "${KONG_HOSTNAME}" = "localhost" ]]; then
    echo "The environment variable KONG_HOSTNAME is not defined or set to localhost."
    export KONG_HOSTNAME="localhost"
    if [ "$(uname)" == "Darwin" ]; then
        sed -i '' "/KONG_HOSTNAME/d" ./kind/kind-config.yaml
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
        sed -i "/KONG_HOSTNAME/d" ./kind/kind-config.yaml
    fi
else
    echo "Using $KONG_HOSTNAME as the hostname."
    if [ "$(uname)" == "Darwin" ]; then
        sed -i '' "s/KONG_HOSTNAME/$KONG_HOSTNAME/g" ./kind/kind-config.yaml
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
        sed -i "s/KONG_HOSTNAME/$KONG_HOSTNAME/g" ./kind/kind-config.yaml
    fi
fi

printf "\nAll dependencies found.  Deploying Kind and Insalling Kong...\n\n"

# Set KUBECONFIG
export KUBECONFIG=$HOME/.kube/config

# Local Environment Variables
export KONG_PROXY_PORT=30000
export KONG_PROXY_HOSTNAME=${KONG_HOSTNAME}
export KONG_SERVICE_HOSTNAME=${KONG_PROXY_HOSTNAME}
export KONG_PROXY_URI=${KONG_PROXY_HOSTNAME}:${KONG_PROXY_PORT}
export KONG_SERVICE_URI=${KONG_PROXY_HOSTNAME}:${KONG_PROXY_PORT}
export KONG_PROXY_URL="http://${KONG_PROXY_URI}"
export KONG_SERVICE_URL="http://${KONG_SERVICE_URI}"

export KONG_ADMIN_API_PORT=30001
export KONG_ADMIN_API_HOSTNAME=${KONG_HOSTNAME}
export KONG_ADMIN_API_URI=${KONG_ADMIN_API_HOSTNAME}:${KONG_ADMIN_API_PORT}
export KONG_ADMIN_API_URL="http://${KONG_ADMIN_API_URI}"

export KONG_MANAGER_PORT=30002
export KONG_MANAGER_HOSTNAME=${KONG_HOSTNAME}
export KONG_MANAGER_URI=${KONG_MANAGER_HOSTNAME}:${KONG_MANAGER_PORT}
export KONG_MANAGER_URL="http://${KONG_MANAGER_URI}"

export KONG_PORTAL_GUI_PORT=30003
export KONG_PORTAL_GUI_HOST=${KONG_HOSTNAME}
export KONG_PORTAL_GUI_URI=${KONG_PORTAL_GUI_HOST}:${KONG_PORTAL_GUI_PORT}
export KONG_PORTAL_GUI_URL="http://${KONG_PORTAL_GUI_URI}"

export KONG_PORTAL_API_PORT=30004
export KONG_PORTAL_API_HOSTNAME=${KONG_HOSTNAME}
export KONG_PORTAL_API_URI=${KONG_PORTAL_API_HOSTNAME}:${KONG_PORTAL_API_PORT}
export KONG_PORTAL_API_URL="http://${KONG_PORTAL_API_URI}"

# Keycloak for External IDP OIDC Plugin exercises
export KEYCLOAK_PORT=8080
export KEYCLOAK_HOSTNAME=${KONG_HOSTNAME}
export KEYCLOAK_URI=${KEYCLOAK_HOSTNAME}:${KEYCLOAK_PORT}
export KEYCLOAK_URL="http://${KEYCLOAK_URI}"
export KEYCLOAK_CONFIG_ISSUER="http://${KEYCLOAK_URI}/auth/realms/kong/.well-known/openid-configuration"
export CLIENT_SECRET="681d81ee-9ff0-438a-8eca-e9a4f892a96b"
export KEYCLOAK_REDIRECT_URI=${KONG_SERVICE_URI}
export KEYCLOAK_REDIRECT_URL=${KONG_SERVICE_URL}

# Prometheus for K8s Control Plane and Kong Analytics
export PROMETHEUS_PORT=30006
export PROMETHEUS_HOSTNAME=${KONG_HOSTNAME}
export PROMETHEUS_URI=${PROMETHEUS_HOSTNAME}:${PROMETHEUS_PORT}
export PROMETHEUS_URL="http://${PROMETHEUS_URI}"

# Grafana for K8s Control Plane and Kong Analytics
export PROMETHEUS_PORT=30006
export PROMETHEUS_HOSTNAME=${KONG_HOSTNAME}
export PROMETHEUS_URI=${KONG_HOSTNAME}:${PROMETHEUS_PORT}
export PROMETHEUS_URL="http://${PROMETHEUS_URI}"
export GRAFANA_PORT=30005
export GRAFANA_HOSTNAME=${KONG_HOSTNAME}
export GRAFANA_URI=${KONG_HOSTNAME}:${GRAFANA_PORT}
export GRAFANA_URL="http://${GRAFANA_URI}"

# Get Current Directory
CURRENTDIR=`pwd`

# Teardown
./scripts/teardown.sh

# Deploy
./scripts/deploy.sh

# Deploy Keycloak IDP Container
cd ./keycloak-idp
docker-compose up -d

# Change back to directory
cd $CURRENTDIR

echo ""
echo "KONG GATEWAY API PROXY URL: $KONG_PROXY_URL"
echo "KONG ADMIN API URL: $KONG_ADMIN_API_URL"
echo "KONG MANAGER URL: $KONG_MANAGER_URL"
echo "KONG PORTAL URL: $KONG_PORTAL_GUI_URL"
echo "Keycloak URL: $KEYCLOAK_URL"
echo "Prometheus URL: $PROMETHEUS_URL"
echo "Grafana URL: $GRAFANA_URL"
echo ""