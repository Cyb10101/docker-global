# Documentation

## Differences between production and development

I have combined this project and it is now usable for development or on the production server.

The project is built more for development. Global Docker containers are used to intercept emails, but Let's Encrypt is not used. Each website itself has its own development container.

On the production system everything is usually reversed. This means you don’t want every dashboard available online. You need a real mail server and so on.

## Security note

If you connect other instances with same volumes, for example a global read only SSH key or a Composer cache directory, other users can have access to private content. If you really need it, it is safer to store it in your own instance.

Always think about what you are doing.

## Create a development system

Follow the guide:

* An Ubuntu desktop is quite sufficient
* [Install Docker](install-docker.md)
* [Configure docker global](configure-docker-global.md)
* Optional: [Configure database](configure-database.md)

## Create a production server

Follow the guide:

* [Production server](production-server.md)
* [Install Docker](install-docker.md)
* [Configure docker global](configure-docker-global.md)
* [Configure database](configure-database.md)
* [User ssh server](user-ssh-server.md)
* [Mail server](mail-server.md)

## Create websites

Some docker container for websites:

* [Cyb10101/php-dev: Github](https://github.com/Cyb10101/php-dev)
* [cyb10101/php-dev: Dockerhub](https://hub.docker.com/r/cyb10101/php-dev)
* [webdevops/php-apache-dev](https://hub.docker.com/r/webdevops/php-apache-dev)
* [webdevops/php-nginx-dev](https://hub.docker.com/r/webdevops/php-nginx-dev)

## Local DNS server

For a cool forwarding of the domains by means of local DNS:

* [DNS server](dns-server.md)

## Database

Creating database dump:

```bash
./start.sh exec global-db sh -c 'exec mysqldump --all-databases -uroot -p"${MARIADB_ROOT_PASSWORD}"' > all-databases.sql
```

Restoring data from dump files:

```bash
./start.sh exec -i global-db sh -c 'exec mysql -uroot -p"${MARIADB_ROOT_PASSWORD}"' < all-databases.sql
```

Upgrade Database from 10.x:

* [Upgrading MariaDB](https://mariadb.com/kb/en/upgrading/)

```bash
./start.sh down && ./start.sh up
./start.sh exec global-db sh -c 'exec mariadb-upgrade -uroot -p"${MARIADB_ROOT_PASSWORD}"'
```
