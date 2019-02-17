#!/bin/bash

BACKUP_FILE="db_`date +%Y-%m-%d`.dump"

cd "$( dirname "${BASH_SOURCE[0]}" )"


stop_and_flush() {
    docker-compose stop miniflux

    ## flush user sessions
    docker-compose run --rm miniflux miniflux -flush-sessions
}

backup() {
    docker-compose exec db pg_dump -U miniflux miniflux > ${BACKUP_FILE}

    source .restic.env
    restic backup ${BACKUP_FILE}
    echo "removing local backup..."
    rm ${BACKUP_FILE}
}

migrate() {
    docker-compose rm --force miniflux

    ## migrate db
    echo "migrating..."
    docker-compose run --rm miniflux miniflux -migrate
}


IMAGE_BEFORE_PULL=`docker image inspect miniflux/miniflux --format="{{.Config.Image}}"`
docker pull miniflux/miniflux
IMAGE_AFTER_PULL=`docker image inspect miniflux/miniflux --format="{{.Config.Image}}"`

if [ "${IMAGE_BEFORE_PULL}" != "${IMAGE_AFTER_PULL}" ]; then
    # we need to update

    ## stop miniflux
    echo "stopping..."
    stop_and_flush

    ## make backup
    # docker-compose exec -u <your_postgres_user> <postgres_service_name> pg_dump -Fc <database_name_here> > db.dump
    echo "backing up..."
    backup

    ## delete container
    echo "deleting container..."
    migrate

    ## start!
    echo "done, starting!"
    docker-compose up -d

else
    # nothing changed, just backup
    echo "backing up..."
    backup
fi