#!/bin/sh
export SERVER_JAR=$(ls | grep 'forge-1.12.2-' | head -n 1)

# Set up pack mode
PACK_MODE=${PACK_MODE:-normal}
echo "Setting up pack mode to be ${PACK_MODE}"
sed -i -re "s/S:packMode=.+/S:packMode=${PACK_MODE}/g" config/packmode.cfg

# You can edit these values if you wish.
MIN_RAM=${MIN_RAM:-"1024M"}
MAX_RAM=${MAX_RAM:-"4096M"}
JAVA_PARAMETERS="-XX:+UseG1GC -Dsun.rmi.dgc.server.gcInterval=2147483646 -XX:+UnlockExperimentalVMOptions -XX:G1NewSizePercent=20 -XX:G1ReservePercent=20 -XX:MaxGCPauseMillis=50 -XX:G1HeapRegionSize=32M -Dfml.readTimeout=180"

java -server -Xms${MIN_RAM} -Xmx${MAX_RAM} ${JAVA_PARAMETERS} -jar ${SERVER_JAR} nogui
