FROM openjdk:8-jre-alpine
LABEL author Denis Luchkin-Zhou <wyvernzora@gmail.com>

ARG SERVER_ROOT="/minecraft"
ARG CONFIG_ROOT="/var/minecraft"
ENV SERVER_ROOT "${SERVER_ROOT}"
ENV CONFIG_ROOT "${CONFIG_ROOT}"

COPY . ${CONFIG_ROOT}

USER root
WORKDIR ${SERVER_ROOT}
RUN "${CONFIG_ROOT}/scripts/setup.sh"

# Start the server
USER minecraft
EXPOSE 25565
VOLUME "${SERVER_ROOT}/data"
CMD ${CONFIG_ROOT}/launch.sh
