#!/usr/bin/env bash
set -e; # Exit on error

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

isContextDevelopment() {
    APP_ENV=${APP_ENV:-}
    if [ "${APP_ENV}" == "dev" ]; then
        echo 1; return;
    fi
    echo 0;
}

setDockerComposeFile() {
    local developmentSuffix=''
    if [ "$(isContextDevelopment)" == "1" ]; then
        developmentSuffix='.dev'
    fi

    DOCKER_COMPOSE_FILE="compose${developmentSuffix}.yaml"
    if [ -e "compose${developmentSuffix}.yml" ]; then
        DOCKER_COMPOSE_FILE="compose${developmentSuffix}.yml"
    elif [ -e "docker-compose${developmentSuffix}.yaml" ]; then
        DOCKER_COMPOSE_FILE="docker-compose${developmentSuffix}.yaml"
    elif [ -e "docker-compose${developmentSuffix}.yml" ]; then
        DOCKER_COMPOSE_FILE="docker-compose${developmentSuffix}.yml"
    fi
}

dockerComposeCmd() {
    docker-compose -f "${DOCKER_COMPOSE_FILE}" "${@:1}"
}

loadEnvironmentVariables
setDockerComposeFile
if [ ! -e "${DOCKER_COMPOSE_FILE}" ]; then
    echo "Docker compose file '${DOCKER_COMPOSE_FILE}' not found!"; exit 1
fi

startFunction() {
    case ${1} in
        upgrade)
            git fetch && git checkout master && git pull
        ;;
        start)
            startFunction pull && \
            startFunction build && \
            startFunction up
        ;;
        up)
            dockerComposeCmd up -d
        ;;
        stopOther)
            containers=$(docker ps --filter network=global -q)
            if [[ "$containers" ]]; then
                docker stop $(printf "%s" "${containers}")
            fi
        ;;
        down)
            #startFunction stopOther
            dockerComposeCmd down --remove-orphans
        ;;
        stop)
            #startFunction stopOther
            dockerComposeCmd stop --remove-orphans
        ;;
        mariadb)
            # ./start.sh mysql databaseName < ~/Downloads/import.sql
            dockerComposeCmd exec -T global-db bash -c 'mariadb -p${MARIADB_ROOT_PASSWORD} "$@"' dummy "${@:2}"
            echo "${@:2}"
        ;;
        mariadb-dump)
            # ./start.sh mysqldump databaseName > ~/Downloads/export.sql
            dockerComposeCmd exec -T global-db bash -c 'mariadb-dump -p${MARIADB_ROOT_PASSWORD} "$@"' dummy "${@:2}"
            echo "${@:2}"
        ;;
        mysql)
            # ./start.sh mysql databaseName < ~/Downloads/import.sql
            dockerComposeCmd exec -T global-db bash -c 'mysql -p${MARIADB_ROOT_PASSWORD} "$@"' dummy "${@:2}"
            echo "${@:2}"
        ;;
        mysqldump)
            # ./start.sh mysqldump databaseName > ~/Downloads/export.sql
            dockerComposeCmd exec -T global-db bash -c 'mysqldump -p${MARIADB_ROOT_PASSWORD} "$@"' dummy "${@:2}"
            echo "${@:2}"
        ;;
        *)
            dockerComposeCmd "${@:1}"
        ;;
    esac
}

docker network inspect global &>/dev/null || docker network create global
startFunction "${@:1}"
exit $?
