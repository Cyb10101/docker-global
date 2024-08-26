# Reverse DNS

If you want a mail server, you must set a reverse DNS (rDNS).

Generic domain names (host123456789.example.org) are bad! Best practise is to use a toplevel domain (example.org), which you never change.

## Configure reserve dns

Configure reserve dns on your hoster:

* **Netcup** Server-Login > Choose Server > Network > IPv4 (rDNS) = mail.example.org
* **Strato** Server-Login > Domains > DNS-Reverse > FQDN (Fully Qualified Domain Name) = mail.example.org

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

Online tests:

* [MxToolbox: SuperTool](https://mxtoolbox.com/SuperTool.aspx) > Test Email Server

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

Get Pointer Record (PTR) from IP:

```bash
dig +noall +answer -x 123.3.2.1
# 1.2.3.123.in-addr.arpa. 1800 IN  PTR  server.com.
```

Check PTR from arpa:

```bash
dig +short 1.2.3.123.in-addr.arpa PTR
# server.com.
```

Check if mail server responds (Status 220) with the same url like PTR:

```bash
telnet smtp.cyb21.de 25
# 220 mail.server.com ESMTP

# For new servers with ESMTP (Extended Simple Message Transfer Protocol)
EHLO example.org
# 250 mail.server.com

# For old servers with SMTP (Simple Message Transfer Protocol)
#HELO example.org
# 250 mail.server.com

QUIT
```
