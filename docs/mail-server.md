# Mail server

Your life isn't bad enough? Then just add a mail server.

* [docker-mailserver/docker-mailserver](https://github.com/docker-mailserver/docker-mailserver)

## Requirements

You should have these domains:

* mail.com or mail.mail.com
* pop.mail.com
* imap.mail.com
* smtp.mail.com

## Quick setup

Copy files:

```bash
rsync -a ~/projects/global/examples/mail ~/projects/
cd ~/projects/mail
```

Open 'docker-compose.yml' and replace:

* `mail.org` and `mail\\.org` to your domain
* Optional: `mail_www`, `mail_redirect` and `mail_autoconfig`

Change Roundcubemail database password `ROUNDCUBEMAIL_DB_PASSWORD`.

@todo regular expression?
@todo multiline label?
Change in service `autodiscover` environment variable `COMPANY_NAME` and add each domain after label `traefik.http.routers.mail_autoconfig.rule=`.

## Roundcube

Login and create a database:

```bash
~/projects/global/start.sh mysql
```

```sql
CREATE DATABASE `roundcube`;
CREATE USER 'roundcube'@'%' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON `roundcube`.* TO 'roundcube'@'%';
FLUSH PRIVILEGES;
```

*Note: If you change roundcube plugins or configuration, you maybe need to delete this folder `.docker/roundmail`. But be careful! Manual configurations could have been written in `.docker/roundmail/config/config.inc.php`.*

## Autoconfig and AutoDiscover

This service is optional and is used to ensure that the mail programs receive the configuration automatically. But I would recommend it because most of the time users make mistakes while setting up an email account.

Configure service `autodiscover` in `docker-compose.yml` file.

* [Monogramm/autodiscover-email-settings](https://github.com/Monogramm/autodiscover-email-settings)
* [Mozilla Autoconfig](https://developer.mozilla.org/en-US/docs/Mozilla/Thunderbird/Autoconfiguration/FileFormat/HowTo)

## Start mail

```bash
cd  ~/projects/mail
./start.sh start

./start.sh setup help
```

## Certificate test

Test if the certificate works.

For the test on the server `0.0.0.0` and for the outside the domain or IP `mail.org`.

```bash
mailServer=0.0.0.0
mailServer=mail.org

# POP3, IMAP, SMTP, Alternative SMTP
openssl s_client -connect ${mailServer}:110 -starttls pop3
openssl s_client -connect ${mailServer}:143 -starttls imap
openssl s_client -connect ${mailServer}:25 -starttls smtp
openssl s_client -connect ${mailServer}:587 -starttls smtp

# POP3, IMAP, SMTP
openssl s_client -connect ${mailServer}:995
openssl s_client -connect ${mailServer}:993
openssl s_client -connect ${mailServer}:465
```

## Add mail address

Add a mailbox or a mail forwardings:

```bash
./start.sh setup email list
./start.sh setup email add user@website.com

./start.sh setup alias list
./start.sh setup alias add from@website.com to@website.com
```

If you add a new domain, be sure you configured SPF and DKIM (See below).

### SPF

The simplest thing you can do is that only the current IP of your server is authorized to send emails.

To do this, a TXT entry on your DNS Server must be created for your domain `website.com`.

```text
v=spf1 a mx ip4:192.1.2.3 ~all
```

### DKIM

Generate DKIM keys:

```bash
./start.sh setup config dkim
ls -1 .docker/mail/config/opendkim/keys
cat .docker/mail/config/opendkim/keys/website.com/mail.txt
./start.sh down && ./start.sh up
```

The quotes must be combined:

```text
mail._domainkey IN TXT ( "v=DKIM1; h=sha256; k=rsa; p=MII/Long+Code/V1wIDAQAB" )
```

Then you need to create a subdomain named `mail._domainkey`. The full domain is then `mail._domainkey.website.com`.

The code `v=DKIM1; h=sha256; k=rsa; p=MII/Long+Code/V1wIDAQAB` must then be added as a `TXT` entry.

### SPF and DKIM test

You can check this on this page: https://www.mail-tester.com/spf-dkim-check

* Domain: website.com
* Selector: mail (Standard is maybe 'default')

or manually:

```bash
dig +noall +answer website.com TXT
# website.com. 3600 IN TXT "v=spf1 a mx ip4:123.3.2.1 ~all"

dig +noall +answer mail._domainkey.website.com TXT
# mail._domainkey.website.com. 3491 IN TXT "v=DKIM1; h=sha256; k=rsa; p=MII/Long+Code/V1wIDAQAB"
```

## Reverse DNS

Test the [Reserve DNS](reserve-dns.md).

## Open relay test

Test if the open relay is deactivated. Spamers use open relays to send fake emails.
It is better to use real email addresses for the test.

```bash
telnet mail.server.com 25
HELO other.com
MAIL FROM: user@other.com
RCPT TO:<user@gmail.com>
# 554 5.7.1 <user@gmail.com>: Relay access denied
QUIT
```

A look at the logs while sending, for example, reveals whether something is blocked somewhere.

```bash
docker-compose logs -f
```

To temporarily bypass certain blockages, you can set this a Docker environment variable:

```bash
POSTSCREEN_ACTION=ignore
```

## SPAM: Spamassassin

Spamassassin learns automatically:

```bash
mkdir -p ~/projects/mail/.docker/mail/cron
vim ~/projects/mail/.docker/mail/cron/sa-learn
# Copy file .docker/mail/cron/sa-learn
```

Test spamassassin with E-Mail:

```bash
spamassassin -t -D < "/tmp/mail.eml"
```

## SPAM: Sieve

Global Sieve spam filter:

```bash
vim ~/projects/mail/.docker/mail/before.dovecot.sieve
vim ~/projects/mail/.docker/mail/after.dovecot.sieve
# Copy and ajust file .docker/mail/*.dovecot.sieve
```

## Roundcube: Configure

Edit `~/projects/mail/.docker/roundmail/config/config.inc.php` and add:

```php
  $config['htmleditor'] = 4; // always compose html formatted messages, except when replying to plain text message
```

## Roundmcube: ManageSieve (Filter)

Enable `ENABLE_MANAGESIEVE` and add RoundCube plugin `ROUNDCUBEMAIL_PLUGINS=managesieve` in `docker-compose.yaml`.

Edit `~/projects/mail/.docker/roundmail/config/config.inc.php` and add:

```php
    $config['managesieve_host'] = 'mail.server.com';
    $config['managesieve_usetls'] = true;
```
