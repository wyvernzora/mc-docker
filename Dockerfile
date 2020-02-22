FROM openjdk:8-jre-alpine
LABEL author Denis Luchkin-Zhou <wyvernzora@gmail.com>

ARG MODPACK
ARG SERVER_DOWNLOAD_URL
ARG SERVER_ROOT="/minecraft"
ARG CONFIG_ROOT="/var/minecraft-scripts"
ENV CONFIG_ROOT "${CONFIG_ROOT}"

COPY scripts/*.sh ${CONFIG_ROOT}/
COPY modpacks/${MODPACK}/* ${CONFIG_ROOT}/modpack/

USER root
WORKDIR /minecraft
RUN "${CONFIG_ROOT}/setup.sh"

# Start the server
USER minecraft
EXPOSE 25565
VOLUME "${SERVER_ROOT}/data"
CMD ${CONFIG_ROOT}/launch.sh
