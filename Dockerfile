ARG BASE_IMAGE=eclipse-temurin:21-jre-jammy
FROM ${BASE_IMAGE}
LABEL org.opencontainers.image.authors="Maksymilian Słowiński mslowinski96@gmail.com"


ARG SERVER_PORT=25565
ARG RCON_PORT=25575

ARG SCRIPTS_FOLDER=./Scripts

ARG USER=minecraft
ARG GROUP=minecraft

#Do not overwrite this, when editing remember to edit entrypoint too
ENV SCRIPTS_PATH=/opt/mc-server-scripts
#Do not overwrite this
ENV SERVER_PATH=/mc-server


ENV START_SCRIPT=start.sh
ENV SERVER_PACK_URL=""
ENV EULA=""
ENV JVM_XMX=8G
ENV JVM_XMS=4G


RUN apt-get update && apt-get install -y curl unzip && rm -rf /var/lib/apt/lists/*

RUN groupadd -r -g 999 ${GROUP} && \
    useradd -r -m -u 999 -g ${GROUP} -d ${SERVER_PATH} -s /bin/false ${USER}

WORKDIR ${SERVER_PATH}

COPY --chown=${USER}:${GROUP} --chmod=u+x ${SCRIPTS_FOLDER}/* ${SCRIPTS_PATH}/


USER ${USER}
EXPOSE ${PORT}
EXPOSE ${RCON_PORT}

#Make sure to keep it the same path as script path
ENTRYPOINT ["/opt/mc-server-scripts/ContainerStart.sh"]
