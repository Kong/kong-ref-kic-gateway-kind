# Kong API Gateway EE on a local KIND k8s cluster

## Requirements
This branch assumes the following commands and tools are installed:
1. kind
2. kubectl
3. openssl
4. docker
5. docker-compose
6. helm
7. python3
8. $KONG_LICENSE needs to be set to the local path of your kong license json file

## Clone Repo and Deploy
```bash
cd $HOME
git clone https://github.com/Kong/kong-ref-kic-gateway-kind.git
cd ./kong-ref-kic-gateway-kind
git checkout bash
source ./redeploy.sh
```

## Teardown
```bash
./scripts/teardown.sh
```
