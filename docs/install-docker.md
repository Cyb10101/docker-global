# Install Docker

* [Docker on Ubuntu](https://docs.docker.com/engine/install/ubuntu/)
* [Docker Compose releases](https://github.com/docker/compose/releases)

Install Docker from Ubuntu repository:

```bash
sudo apt -y install docker.io
```

If you want run Docker from another user than root:

```bash
sudo usermod -aG docker ${USER}
```

Install Docker Compose:

```bash
sudo apt -y install jq
VERSION=$(curl -fsSL https://api.github.com/repos/docker/compose/releases/latest | jq -r '.name')
curl --progress-bar -o /tmp/docker-compose -fL "https://github.com/docker/compose/releases/download/${VERSION}/docker-compose-$(uname -s)-$(uname -m)"
sudo install /tmp/docker-compose /usr/local/bin/docker-compose
```
