# User SSH server

A simple ssh server for users to access their files.

Copy files, adjust docker compose configuration and start container:

```bash
rsync -a ~/projects/global/examples/user_ssh ~/projects/user_username

~/projects/user_username/start.sh start
```
