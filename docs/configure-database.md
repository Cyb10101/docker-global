# Configure database

During development it is not really necessary to create each user and database separately.
Of course that depends on what you do. If you have a virus-infected instance, you don't have to be surprised if the database is killed.

To ensure that this doesn't happen with the productive system, each website has its own authorization.

## MySQL / MariaDB

*Note: Database username, up to 16 alphanumeric characters, underscore and dash are allowed.*

Start mysql client, login with user `root` and your password:

```bash
~/projects/global/start.sh mysql
```

Create a database and a user:

```sql
CREATE DATABASE `website_www`;
CREATE USER 'username'@'%' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON `website_www`.* TO 'username'@'%';
FLUSH PRIVILEGES;
```

Change user password:

```sql
ALTER USER 'username'@'%' IDENTIFIED BY 'password';
FLUSH PRIVILEGES;
```

Remove a database and a user:

```sql
/* Show database and user */
SELECT Host, Db, User FROM mysql.db;
SELECT User, Host FROM mysql.user;

/* Show grants */
SHOW GRANTS FOR 'username'@'%';

/* Get drop sql */
SELECT CONCAT("DROP DATABASE `", db, "`; DROP USER '", user, "'", "@", "'", HOST, "'; FLUSH PRIVILEGES;") AS `SQL` FROM mysql.db WHERE `Db` IN ('website_www');

/* Drop database and user */
DROP DATABASE `website_www`;
DROP USER 'username'@'%';
FLUSH PRIVILEGES;
```
