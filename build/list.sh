#!/bin/bash
set -e

for config in modpacks/*/modpack.json; do
    echo "$(jq -r '.name' ${config})"
    while read version; do
        echo " - ${version}"
    done <<< "$(jq -r '.versions | keys[]' ${config} | sort)";
    echo
done
