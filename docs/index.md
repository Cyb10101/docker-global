# Documentation

For a cool forwarding of the domains by means of local DNS:

* [DNS Server](dns-server.md)

## HTTPS/SSL encryption

* [Self-Signed Certificate](https-self-signed.md)

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
