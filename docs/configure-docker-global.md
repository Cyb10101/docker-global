# Configure docker global

## Install 'global'

Create a projects folder and clone Git repository:

```bash
mkdir ~/projects
git clone https://github.com/Cyb10101/docker-global.git ~/projects/global

cd ~/projects/global
```

Prepare Let's Encrypt (production):

```bash
#mkdir -p .docker/traefik/acme
#echo '{}' >> .docker/traefik/acme/acme.json
#chmod 600 .docker/traefik/acme/acme.json
```

Create a default self-signed certificate (development):

```bash
sudo mkdir -p .docker/traefik/certs
sudo openssl req -x509 -newkey rsa:4096 -sha256 -days 36500 -nodes \
    -keyout .docker/traefik/certs/default.key \
    -out .docker/traefik/certs/default.crt
```

If you use a development system add:

```bash
# Use application context 'development' (See *.dev.* files)
echo 'APP_ENV=dev' >> .env
```

A small script to perform actions across all projects:

```bash
cp examples/project.sh ../project.sh
#ln -sr examples/project.sh ../project.sh
```

## Docker Compose files

If you look into the docker compose files, you see some differences.

On production & development:

* global-traefik: The reverse proxy
* global-serviceError: Fancy error page for Traefik, if a docker container is down
* global-db: The MariaDB database

On development:

* global-mail: Mail testing tool
* global-portainer: Container management software
* global-dozzle: Docker log viewer

## Traefik

* [Traefik documentation](https://doc.traefik.io/traefik/)

If you use the trafik web interface, generate a password with htpasswd and set it after `traefik.http.middlewares.auth.basicauth.users=`.

```bash
# htpasswd -nb admin "password" | sed -e s/\\$/\\$\\$/g
docker run --rm httpd:2.4-alpine htpasswd -nbB admin "password" | sed -e s/\\$/\\$\\$/g
```

Configure mail for Let's Encrypt in 'traefik/traefik.yaml':

```yaml
certificatesResolvers:
  letsEncrypt:
    acme:
      email: "username@example.org"
```

Add or generate a "Traefik erorr status page". One index.html file should be enough.

```bash
./traefik/status-pages/create.sh
```

## Database

The default credentials are:

* Username: root
* Passwort: root
* Host: global-db (with linked network in container website)

If you are on production, you should set a better `MARIADB_ROOT_PASSWORD`. More later under [Configure docker global](configure-docker-global.md).

## Mail (only development)

If you want to send a mail over SMTP use `global-mail:1025` without username and password.
Check your mailbox here: [Mail](https://mail.localhost).

## Some environment variables

You can create a `.env` file and overwrite some settings:

```bash
# Development application context
APP_ENV=dev

# Restart global containers? https://docs.docker.com/compose/compose-file/#restart
RESTART=always

# Host ports
HTTP_PORT=80
HTTPS_PORT=443
DB_PORT=3306
SMTP_PORT=1025

# IP addresses
HTTP_IP=0.0.0.0
HTTPS_IP=0.0.0.0

# IP addresses (only development)
DB_IP=0.0.0.0
```

## Start global docker container

```bash
~/projects/global/start.sh start
```

Some web interfaces for development:

* [Traefik](https://traefik.localhost/)
* [Portainer](https://portainer.localhost)
* [Dozzle](https://dozzle.localhost/)
* [Mail](https://mail.localhost/)

## Portainer

Go to your [Portainer](https://portainer.localhost) and create a user.

* Add Environments
* Select: Docker Standalone > Click on "Start Wizard" button
* Select Socket > Click on "Close" button

Configure Portainer:

* Settings > Authentification > Session lifetime = 1 year

## Test proxy server

Test the reverse proxy with a simple 'Who am i' website:

```bash
rsync -a ~/projects/global/examples/whoami_www ~/projects/
~/projects/whoami_www/start.sh start
```

Open [Whoami](https://whoami.localhost).
