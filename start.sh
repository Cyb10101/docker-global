#!/usr/bin/env bash
set -e; # Exit on error

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
cd "${SCRIPTPATH}"

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
            docker-compose up -d
        ;;
        stopOther)
            containers=$(docker ps --filter network=global -q)
            if [[ "$containers" ]]; then
                docker stop $(printf "%s" "${containers}")
            fi
        ;;
        down)
            startFunction stopOther
            docker-compose down --remove-orphans
        ;;
        stop)
            startFunction stopOther
            docker-compose stop --remove-orphans
        ;;
        *)
            docker-compose "${@:1}"
        ;;
    esac
}

docker network inspect global &>/dev/null || docker network create global
startFunction "${@:1}"
exit $?

