#!/usr/bin/env bash

alias vesctl='vesctl --config .vesconfig'
# Workload_flavor
vesctl configuration create workload_flavor -i workload_flavor.yaml

# Worload
for item in mongodb spa api inventory recommendations; do
    vesctl configuration create workload -i workload_"$item".yaml
done