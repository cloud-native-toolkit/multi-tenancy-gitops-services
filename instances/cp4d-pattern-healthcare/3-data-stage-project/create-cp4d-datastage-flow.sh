#!/usr/bin/env bash

set -eo pipefail

# Set env var
ADMIN_PWD=$(oc get secret admin-user-details -n tools --template={{.data.initial_admin_password}} | base64 -d)
ZEN_URL=$(oc get zenservice lite-cr --template={{.status.url}})
BEARER_TOKEN=$(curl -k -X POST -H 'cache-control: no-cache' -H 'content-type: application/json' -d "{\"username\":\"admin\",\"password\":\"$ADMIN_PWD\"}" https://$ZEN_URL/icp4d-api/v1/authorize | jq '.token' | tr -d '"')

# Configure cpdctl
cpdctl config user set admin --username=admin --password=$ADMIN_PWD
cpdctl config profile set admin --url https://$ZEN_URL
cpdctl config context set admin --user admin --profile admin
cpdctl config context use admin
cpdctl config context list
cpdctl project list

# Create Data Stage project
cpdctl project create --name healthcare-data-stage --output json --raw-output --jmes-query 'location'

export PROJECT_ID=$(cpdctl project list | grep healthcare-data-stage | awk '{ print $1}')

# Imporot Data Stage project
cpdctl asset import start --project-id $PROJECT_ID --import-file cpd-resources/Healthcare-Data-Stage-Project.zip --output json --jmes-query "metadata.id" --raw-output

# DB2 connection properties
export CREATE_CONN_PROPERTIES='''
{
      "database": "BLUDB",
      "host": "db2.tools.svc.cluster.local",
      "password": "Passw0rd123!",
      "username": "db2inst1",
      "port":"50000"
}
'''

# Retrieve db2 datasource uuid
export DB2_DATASOURCE_TYPE=$(cpdctl connection datasource-type list | grep db2 | awk 'NR==3 { print $1}')

# Retrieve the default Platform assets catalog uuid
export CATALOG_ID=$(curl -H "Authorization: Bearer $BEARER_TOKEN" https://$ZEN_URL/v2/catalogs -kL | jq '.catalogs[] | select(.entity.name == "Platform assets catalog") | .metadata.guid' | tr -d '"')

# Create db2 platform connection
export ASSET_ID=$(cpdctl connection create --name patients --description 'patients database' --datasource-type $DB2_DATASOURCE_TYPE --catalog-id ${CATALOG_ID} --properties "${CREATE_CONN_PROPERTIES}" -j metadata.asset_id --origin-country us --output json -j 'metadata.asset_id' | tr -d '"')




