#!/usr/bin/env bash

set -eo pipefail

# Set env var
ADMIN_PWD=$(oc get secret admin-user-details -n tools --template={{.data.initial_admin_password}} | base64 -d)
ZEN_URL=$(oc get zenservice lite-cr --template={{.status.url}})
BEARER_TOKEN=$(curl -k -X POST -H 'cache-control: no-cache' -H 'content-type: application/json' -d "{\"username\":\"admin\",\"password\":\"$ADMIN_PWD\"}" https://$ZEN_URL/icp4d-api/v1/authorize | jq '.token' | tr -d '"')
API_KEY=$(curl -X GET -H "Authorization: Bearer $BEARER_TOKEN" -H "cache-control: no-cache" https://$ZEN_URL/api/v1/usermgmt/v1/user/apiKey -k | jq '.apiKey' | tr -d '"')

# Configure profile for cpd-cli
./cpd-cli-linux-SE-10.0.3-16/cpd-cli config users set cp4d-pattern --username admin --apikey $API_KEY
./cpd-cli-linux-SE-10.0.3-16//cpd-cli config profiles set cp4d-pattern --user cp4d-pattern --url https://$ZEN_URL

# List existing CP4D users
./cpd-cli-linux-SE-10.0.3-16/cpd-cli user-mgmt list-users --profile cp4d-pattern

# Create new CP4D users
./cpd-cli-linux-SE-10.0.3-16/cpd-cli user-mgmt --profile cp4d-pattern upsert-user --data  /cpd-resources/user-dataengineer.json
./cpd-cli-linux-SE-10.0.3-16/cpd-cli user-mgmt --profile cp4d-pattern upsert-user --data /cpd-resources/user-datascientist.json
./cpd-cli-linux-SE-10.0.3-16/cpd-cli user-mgmt --profile cp4d-pattern upsert-user --data /cpd-resources/user-datasteward.json