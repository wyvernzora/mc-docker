#!/bin/sh
set -e

# Symlink directories into data volume
function symlinkDataDir() {
    if [ ! -L "$1" ]; then
        echo "Symlinking directory $1"
        if [ -d "$1" ]; then
            mv "$1" "data/$1"
        else
            mkdir -p "data/$1"
        fi
        ln -s "data/$1" "$1"
    else
        echo "$1 is already a symlink, skipping"
    fi
}
symlinkDataDir "world"
symlinkDataDir "logs"
symlinkDataDir "backups"

# Create and symlink common configuration files
function symlinkConfigFile() {
    if [ ! -L "$1" ]; then
        echo "Symlinking config file $1"
        if [ -f "$1" ]; then
            mv "$1" "data/$1"
        fi
        ln -nsf "data/$1" "$1"
    else
        echo "$1 is already a symlink, skipping"
    fi
}
symlinkConfigFile "server.properties"
symlinkConfigFile "whitelist.json"
symlinkConfigFile "blacklist.json"
symlinkConfigFile "ops.json"
symlinkConfigFile "banned-ips.json"
symlinkConfigFile "banned-players.json"

# Initialize symlinked directories
mkdir -p data/world
mkdir -p data/logs
mkdir -p data/backups

# Hand off to modpack specific launch script
/bin/sh ${CONFIG_ROOT}/modpack/launch.sh
