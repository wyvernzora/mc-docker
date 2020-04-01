#!/bin/sh
set -e

echo "Server root: ${SERVER_ROOT}"
echo "Config root: ${CONFIG_ROOT}"

# Set up a non privileged user
addgroup minecraft
adduser -D -G minecraft minecraft

# Install dependencies and allow non privileged users to run them
apk add --no-cache -U bash curl
chmod -R u+s /bin

# Extract and otherwise get the server files ready
unzip -o "${CONFIG_ROOT}/server.zip"
rm "${CONFIG_ROOT}/server.zip"

# If the server unzips into a wrapper directory, move all server files
# out to server root
numdirs=$(find * -maxdepth 0 -type d | wc -l)
if [ "${numdirs}" -eq "1" ]; then
    echo "Moving minecraft files to $(pwd)"
    for dir in */; do
        mv "${dir}"/* ./
        rmdir "${dir}"
    done
fi

# Accept EULA.. why bother starting container otherwise?
echo "eula=TRUE" >> eula.txt
echo "eula=true" >> eula.txt

# Run modpack-specific installation steps
if [ -f ${CONFIG_ROOT}/modpack/setup.sh ]; then
    echo "Executing modpack setup script"
    /bin/sh ${CONFIG_ROOT}/modpack/setup.sh
fi

# Create data volume directory
mkdir -p data

# Setup permissions so that server can run as unprivileged user
chown -R minecraft:minecraft .
