#!/bin/bash

BACKUP_FILE="db_`date +%Y-%m-%d`.dump"

cd "$( dirname "${BASH_SOURCE[0]}" )"


## stop miniflux
echo "stopping..."
docker-compose stop miniflux

## flush user sessions
echo "flushing sessions..."
docker-compose run --rm miniflux miniflux -flush-sessions

## make backup
# docker-compose exec -u <your_postgres_user> <postgres_service_name> pg_dump -Fc <database_name_here> > db.dump
echo "backing up..."
docker-compose exec db pg_dump -U miniflux miniflux > ${BACKUP_FILE}

source .restic.env
restic backup ${BACKUP_FILE}
echo "removing local backup..."
rm ${BACKUP_FILE}

## delete container
echo "deleting container..."
docker-compose rm --force miniflux 

## migrate db
echo "migrating..."
docker-compose run --rm miniflux miniflux -migrate

## start!
echo "done, starting!"
docker-compose up -d

