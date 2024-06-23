# DNS Server (example.localhost)

You can use DNS Server for the example.localhost domains to work.
IP address (192.168.56.101) must be adapted for the current environment.
If you use Docker on the localhost, the IP is `127.0.0.1` .

## Linux installation

Some information about dnsmasq:

In the file `/etc/dnsmasq.d/development` you can add as many addresses as you want.

In the first example, all domains ending with .localhost will be redirected to the IP address 192.168.56.101. (example.localhost, sub2.example.localhost, sub2.sub1.example.localhost, ...)

As you can see, this depends more on your network configuration.

```bash
# Redirect *.localhost domains to 192.168.56.101 (Other IP, Virtual Machine)
address=/.localhost/192.168.56.101

# Redirect *.localhost domains to 127.0.0.1 (Local system)
address=/.localhost/127.0.0.1

# Redirect *.vm21.example.org domains to 127.0.0.1 (Another domain)
address=/.vm21.example.org/127.0.0.1
```

### Installation in Debian

Tested on Debian GNU/Linux 9.6 (stretch).

```bash
sudo apt -y install resolvconf dnsmasq
sudo sh -c 'echo "address=/.localhost/127.0.0.1" >> /etc/NetworkManager/dnsmasq.d/development'
sudo sh -c 'echo "address=/.vm21.example.org/127.0.0.1" >> /etc/NetworkManager/dnsmasq.d/development'
sudo systemctl restart dnsmasq
sudo resolvconf -u
```

### Installation in Ubuntu 22.04

Maybe not needed.

```bash
sudo gedit /etc/systemd/resolved.conf
```

Change:

```ini
[Resolve]
DNS=192.168.1.1
Domains=~local ~localhost
MulticastDNS=yes
LLMNR=no
```

```bash
# Get network interface
resolvectl status

cat << EOF | sudo tee /etc/systemd/network/enp0s3.network
[Match]
Name=enp0s3

[Network]
DHCP=yes
MulticastDNS=yes
LLMNR=no
EOF
```

```bash
sudo systemctl daemon-reload
sudo systemctl restart systemd-networkd
sudo systemctl restart systemd-resolved

networkctl list
# LINK   TYPE  OPERATIONAL SETUP
# enp0s3 ether routable    configured
```

### Installation in Ubuntu

Tested on Ubuntu Desktop 20.04.

```Shell
sudo apt -y install resolvconf
sudo vim /etc/NetworkManager/NetworkManager.conf
```

Append to file: /etc/NetworkManager/NetworkManager.conf

```ini
[main]
dns=dnsmasq
```

Run these commands in the shell:

```bash
sudo sh -c 'echo "nameserver 127.0.1.1" >> /etc/resolvconf/resolv.conf.d/head'
sudo sh -c 'echo "nameserver 8.8.8.8" >> /etc/resolvconf/resolv.conf.d/head'
sudo sh -c 'echo "address=/.localhost/192.168.56.101" >> /etc/NetworkManager/dnsmasq.d/development'
sudo sh -c 'echo "address=/.vm21.example.org/192.168.56.101" >> /etc/NetworkManager/dnsmasq.d/development'
sudo systemctl restart network-manager
sudo resolvconf -u
```

## Windows installation (Acrylic DNS Proxy)

Tested on Windows 10.

Download and install: https://mayakron.altervista.org/wikibase/show.php?id=AcrylicHome

Start menu > Control Panel > Network and Internet > Network and Sharing Center > Change adapter settings

Edit network > Internet Protocol Version 4 (TCP/IPv4) > Properties > Use the following DNS server addresses:

* Preferred DNS server: 127.0.0.1

Start menu > Acrylic DNS Proxy > Acrylic UI

* File > Open Acrylic Hosts

Append with your virtual machine IP, depends on your network configuration:

```bash
# Redirect *.localhost domains to 192.168.56.101 (Other IP, Virtual Machine)
192.168.56.101 /.*\.localhost$

# Redirect *.localhost domains to 127.0.0.1 (Local system)
127.0.0.1 /.*\.localhost$

# Redirect *.vm21.iveins.de domains to 192.168.56.101 (Another domain)
192.168.56.101 /.*\.vm21\.example\.org$

# Redirect *.vm21.iveins.de domains to 127.0.0.1 (Local system)
127.0.0.1 /.*\.vm21\.example\.org$
```

Maybe you must restart the Service:

* Actions > Restart Acrylic Service
