# Reverse DNS

If you want a mail server, you must set a reverse DNS.

Generic domain names (host123456789.example.org) are bad! Best practise is to use a toplevel domain (example.org), which you never change.

## Configure reserve dns

Configure reserve dns on your hoster:

* **Netcup** Server-Login > Choose Server > Network > IPv4 (rDNS) = example.org
* **Strato** Server-Login > Domains > DNS-Reverse > FQDN (Fully Qualified Domain Name) = example.org

Set hostname on your server:

```bash
hostnamectl set-hostname server.com
vim /etc/hosts
```

Add 'example.org' in file 'hosts':

```conf
127.0.1.1 example.org v123.server.org
```

## Test reverse dns

*Note: If your mail is not ready set up, do this later.*

Get domain or ip from MX entry:

```bash
dig +noall +answer website.com MX
# website.com.  3600  IN  MX  10 mail.server.com.
```

Get ip from mail domain:

```bash
dig +noall +answer mail.server.com A
# mail.server.com.  3600  IN  A  123.3.2.1
```

Get reverse dns (PTR) from IP:

```bash
dig +noall +answer -x 123.3.2.1
# 1.2.3.123.in-addr.arpa. 1800 IN	PTR	server.com.
```

Check PTR from arpa:

```bash
dig +short 1.2.3.123.in-addr.arpa PTR
# server.com.
```

Test Mail Server if PTR & HELO is the same:

```bash
telnet smtp.server.com 25
# 220 server.com ESMTP
HELO example.org
# 250 server.com
QUIT
```