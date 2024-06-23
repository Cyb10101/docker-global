#!/usr/bin/env bash

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
cd "${SCRIPTPATH}"

loadEnvironmentVariables() {
    if [ -f ".env" ]; then
      source .env
    fi
    if [ -f ".env.local" ]; then
      source .env.local
    fi
}

setDockerComposeFile() {
    DOCKER_COMPOSE_FILE="compose.yaml"
    if [ -e "compose.yml" ]; then
        DOCKER_COMPOSE_FILE="compose.yml"
    elif [ -e "docker-compose.yaml" ]; then
        DOCKER_COMPOSE_FILE="docker-compose.yaml"
    elif [ -e "docker-compose.yml" ]; then
        DOCKER_COMPOSE_FILE="docker-compose.yml"
    fi
}

dockerComposeCmd() {
    docker-compose -f "${DOCKER_COMPOSE_FILE}" "${@:1}"
}

loadEnvironmentVariables
setDockerComposeFile

function startFunction {
    case ${1} in
        start)
            startFunction pull && \
            startFunction build && \
            startFunction up
        ;;
        up)
            dockerComposeCmd up -d
        ;;
        down)
            dockerComposeCmd down --remove-orphans
        ;;
        login)
            startFunction bash
        ;;
        bash)
            dockerComposeCmd exec web bash
        ;;
        setup)
            dockerComposeCmd exec mail /usr/local/bin/setup "${@:2}"
        ;;
	*)
            dockerComposeCmd "${@:1}"
        ;;
    esac
}

startFunction "${@:1}"
exit $?
