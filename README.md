# GAzie Docker Unofficial

Forked from https://github.com/danelsan/gazie-docker

ATTUALMENTE IN ALPHA. USATELO A VOSTRO RISCHIO E PERICOLO.

## TODO
* Consentire personalizzazione nomi container, database, user e password  per riferimenti DB
* Verificare Invio mail

## Getting started
```
 git clone https://github.com/GabrieleV/gazie-docker.git
 cd gazie-docker
 ln -s docker-compose-prod.yml docker-compose.yml
 docker compose up
```

* http://x.y.z:8175

* Utilizzare le credenziali di default: amministratore/password

* That's it !

## Importare dati da un'altra installazione GAzie

* Esportare il DB con l'opzione DROP TABLES
* Salvare il file esportato in docker-entrypoint-initdb.d/zz-mydata.sql
* Copiare i files dalla precedente data/ in ./data

That's it !

# SVILUPPO

* Creare l'immagine con
    ./build.sh <version>

* Linkare il docker.compose.yml alla versione di test:
    ln -s docker-compose-test.yml docker-compose.yml

* Avviare:
    docker compose up

