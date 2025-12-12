#!/usr/bin/env bash

alias vesctl='vesctl --config .vesconfig'
# Workload_flavor
vesctl configuration delete workload_flavor tsanghan-brewz-large-flavor

# Worload
for item in mongodb spa api inventory recommendations; do
    vesctl configuration delete workload "$item" --namespace tsanghan-brewz
done