# Production server

Choose a host that provides you with a virtual private server or a root server.

This guide is based on an Ubuntu server 22.04.

## Security

Generate a SSH key on your local machine.

```bash
ssh-keygen -t rsa -b 4096 -C 'user@example.org'
```

Login to your server, change root password and create a new user:

```bash
ssh root@server.com
passwd root
adduser username
logout
```

Copy local ssh public key to server:

```bash
ssh-copy-id -i ~/.ssh/id_rsa.pub root@server
ssh-copy-id -i ~/.ssh/id_rsa.pub username@server
```

Test login with SSH key:

```bash
ssh root@server.com
ssh username@server.com
```

## Install applications

```bash
apt -y install curl jq ncdu htop vim \
  restic rdiff-backup
```

### SSH root login

```bash
vim /etc/ssh/sshd_config
```

Choose your configuration:

```conf
# Disable passwort login
PermitRootLogin prohibit-password

# Disable all
PermitRootLogin no

# Change your ip and port (advanced)
Port 2200
ListenAddress 0.0.0.0
ListenAddress ::
```

Restart SSH daemon:

```bash
systemctl restart ssh
```

**Don't forget to check ssh login!**

## Motd (Message of the day)

To disable all messages for current user:

```bash
touch ~/.hushlogin
```

Disable last ssh login with `PrintLastLog no`:

```bash
vim /etc/ssh/sshd_config
systemctl restart ssh
```

Disable specified Motd's:

```bash
chmod -x /etc/update-motd.d/00-header
chmod -x /etc/update-motd.d/10-help-text
chmod -x /etc/update-motd.d/50-landscape-sysinfo
chmod -x /etc/update-motd.d/50-motd-news
chmod -x /etc/update-motd.d/80-livepatch
```

## Fail2Ban

```bash
apt install fail2ban
vim /etc/fail2ban/jail.d/jail.local
```

Change your server ip and destination email address:

```conf
[DEFAULT]
ignoreip = 127.0.0.1/8 your_server_ip
#mta = mail
destemail = user@example.org
#sendername = Fail2BanAlerts
maxretry = 3
findtime = 600
bantime = 600
```

Restart fail2ban:

```bash
service fail2ban restart
fail2ban-client status
fail2ban-client status sshd
```

**Don't forget to check ssh login!**

## Server: date & time

The date and time of the server should always be correct.

```bash
timedatectl status

# Activate or force synchronization now
timedatectl set-ntp 0
timedatectl set-ntp 1
```

## Configure DNS Server

* A-Record: Your IPv4 server address
* MX-Record: Your default mail domain
* TXT-Record: A SPF-Record, that your domain is allowed to send mails over your server

```bash
A: 123.3.2.1 (Your server IPv4)
MX: mail.example.org
TXT: v=spf1 a mx ip4:123.3.2.1 ~all
```

## Reverse DNS

Configure the [Reserve DNS](reserve-dns.md).

## SSH/Deploy key

You can add an SSH key on your server if you want to use it to pull a Git repository:

```bash
ssh-keygen -t rsa -b 4096 -C 'production-servername'
```
