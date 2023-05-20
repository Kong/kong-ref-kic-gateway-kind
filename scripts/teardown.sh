#!/usr/bin/env bash
export KUBECONFIG=$HOME/.kube/config

# Get Current Directory
CURRENTDIR=`pwd`

# Delete kind cluster
kind delete cluster --name multiverse

# Bring down docker containers
cd ./keycloak-idp
docker-compose down
cd $CURRENTDIR
