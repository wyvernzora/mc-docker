#!/bin/sh

# Set up override args
echo "MAX_RAM=${MAX_RAM:-2G}" > settings-local.sh

/bin/bash ServerStart.sh
