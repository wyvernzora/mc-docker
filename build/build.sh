#!/bin/bash
set -e

# Constructs the path of the modpack config file
function getModpackConfigPath() {
    modpack=${1}
    echo "modpacks/${modpack}/modpack.json"
}

# Constructs the path to the cached server file of the modpack
function getModpackCachePath() {
    modpack=${1}
    version=${2}
    echo ".cache/${modpack}/${version}"
}

# Gets a list of all modpack versions available
function getModpackVersions() {
    modpack=${1}
    jq -r '.versions | keys[]' "$(getModpackConfigPath ${modpack})" | sort
}

# Gets the latest version of the modpack
function getLatestModpackVersion() {
    modpack=${1}
    getModpackVersions "${modpack}" | tail -n 1
}

# Builds a specified version of a modpack, falling back to latest if no versions are specified
function buildModpack() {
    modpack=${1}
    if [ ! -f "$(getModpackConfigPath ${modpack})" ]; then
        echo "Could not find modpack ${modpack}"
        exit 1
    fi

    # Determine the version to build, and corresponding server archive download URL
    version=${2:-$(getLatestModpackVersion ${modpack})}
    downloadUrl=$(jq -r ".versions[\"${version}\"]" "$(getModpackConfigPath ${modpack})")
    if [ -z "${downloadUrl}" ]; then
        echo "Could not find version ${version} of modpack ${modpack}"
        exit 1
    fi

    # Set up files for container
    cachePath="$(getModpackCachePath ${modpack} ${version})"
    mkdir -p "${cachePath}"
    cp -r "modpacks/${modpack}" "${cachePath}/modpack"
    cp -r "scripts" "${cachePath}/"
    cp Dockerfile "${cachePath}"

    if [ ! -f "${cachePath}/server.zip" ]; then
        echo "Downloading server archive..."
        curl "${downloadUrl}" -o "${cachePath}/server.zip"
    fi

    # Resolve appropriate docker image tags
    tags="--tag ${USER}/minecraft-${modpack}:${version}"
    if [ "${version}" == "$(getLatestModpackVersion ${modpack})" ]; then
        tags="${tags} --tag ${USER}/minecraft-${modpack}:latest"
    fi

    # Build the container image
	docker build "${cachePath}" ${tags}
}

MODPACK=$(echo "${1}:" | cut -d ':' -f 1)
VERSION=$(echo "${1}:" | cut -d ':' -f 2)
buildModpack "${MODPACK}" "${VERSION}"
