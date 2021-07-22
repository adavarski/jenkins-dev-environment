Run `bitbucket-restore-application-data.sh` to restore application data if needed.

Run `bitbucket-restore-database.sh` to restore database if needed.

Deploy development environment with Bitbucket backups implemented with a Docker Compose using the command:

```
docker-compose -f docker-compose-bb-backups.yml -p bitbucket up -d
```
