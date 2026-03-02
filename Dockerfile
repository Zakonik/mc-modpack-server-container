ARG BASE_IMAGE=eclipse-temurin:21-jdk-jammy
FROM ${BASE_IMAGE}
LABEL org.opencontainers.image.authors="Maksymilian Słowiński mslowinski96@gmail.com"


ARG PORT=25565

ARG SCRIPTS_FOLDER=./Scripts

ARG USER=minecraft
ARG GROUP=minecraft


ENV SCRIPTS_PATH=/opt/mc-server-scripts
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

ENTRYPOINT ["/opt/mc-server-scripts/ContainerStart.sh"]
