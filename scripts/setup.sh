#!/bin/sh
set -e

SERVER_ROOT=$(pwd)
CONFIG_ROOT=$(dirname $0)

echo "Server root: ${SERVER_ROOT}"
echo "Config root: ${CONFIG_ROOT}"

# Set up a non privileged user
addgroup minecraft
adduser -D -G minecraft minecraft

# Install dependencies and allow non privileged users to run them
apk add --no-cache -U bash curl
chmod -R u+s /bin

# Download, extract and otherwise get the server files ready
echo "Downloading server archive from ${SERVER_DOWNLOAD_URL}"
curl "${SERVER_DOWNLOAD_URL}" -o "$TMPDIR/server.zip"
unzip -o "$TMPDIR/server.zip"
rm "$TMPDIR/server.zip"

# If the server unzips into a wrapper directory, move all server files
# out to server root
numdirs=$(find * -maxdepth 0 -type d | wc -l)
if [ "${numdirs}" -eq "1" ]; then
    echo "Moving minecraft files to $(pwd)"
    for dir in $(ls); do
        mv ${dir}/* ./
        rmdir ${dir}
    done
fi

# Accept EULA.. why bother starting container otherwise?
echo "eula=TRUE" >> eula.txt
echo "eula=true" >> eula.txt

# Run modpack-specific installation steps
if [ -f ${CONFIG_ROOT}/modpack/setup.sh ]; then
    /bin/sh ${CONFIG_ROOT}/modpack/setup.sh
fi

# Create data volume directory
mkdir -p data

# Setup permissions so that server can run as unprivileged user
chown -R minecraft:minecraft .
