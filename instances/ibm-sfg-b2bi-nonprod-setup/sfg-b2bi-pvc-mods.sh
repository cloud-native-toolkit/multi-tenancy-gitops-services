#!/usr/bin/env bash

NS="b2bi-nonprod"
RWX_STORAGECLASS=${RWX_STORAGECLASS:-managed-nfs-storage}

echo "Building Logs PVC"
( echo "cat <<EOF" ; cat ibm-sfg-b2bi-sfg-logs-pvc.yaml_template ;) | \
RWX_STORAGECLASS=${RWX_STORAGECLASS} \
NS=${NS} \
sh > ibm-sfg-b2bi-sfg-logs-pvc.yaml

echo "Building Documents PVC"
( echo "cat <<EOF" ; cat ibm-sfg-b2bi-sfg-documents-pvc.yaml_template ;) | \
RWX_STORAGECLASS=${RWX_STORAGECLASS} \
NS=${NS} \
sh > ibm-sfg-b2bi-sfg-documents-pvc.yaml

echo "Building Resources PVC"
( echo "cat <<EOF" ; cat ibm-sfg-b2bi-sfg-resources-pvc.yaml_template ;) | \
RWX_STORAGECLASS=${RWX_STORAGECLASS} \
NS=${NS} \
sh > ibm-sfg-b2bi-sfg-resources-pvc.yaml

echo "Done"