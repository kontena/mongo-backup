# mongo-backup
>Automated backups for MongoDB containers

This Docker image runs mongodump to backup data to folder `/backup`. The image uses [backup](http://backup.github.io/backup/v4/) Ruby gem to create backups and [rufus-scheduler](https://github.com/jmettraux/rufus-scheduler) gem for scheduling.

## Backup interval
Backup interval can be set by `INTERVAL` environment variable. Value can be:
* number of seconds: `30`
* minutes: `1m`
* hours: `1h`
* days: `1d`
* cron format: `0 22 * * *`

## Storages

You can store your backup:

* Amazon S3
* Dropbox
* RSync
* SFTP

## Notifiers
Notifiers are used to send notifications upon successful and/or failed completion of your backup

Supported notification services include:

* Slack
* Flowdock
* Email
* DataDog
* Pagerduty

## Example: Backup to S3 every day

```
export MONGO_BUCKET=<Your S3 bucket name>
export SLACK_WEBHOOK_URL=<Your Slack webhook url>
export MONGO_CONTAINER=<Your MongoDB container name>
docker run --name mongo-backup \
  --link $MONGO_CONTAINER:mongo \
  -e MONGODB_HOST=mongo \
  -e INTERVAL=1d \
  -e S3_ACCESS_KEY_ID=<YOUR AWS ACCESS KEY> \
  -e S3_SECRET_ACCESS_KEY=<YOUR AWS ACCESS KEY> \
  -e S3_REGION=eu-west-1 \
  -e S3_BUCKET=$MONGO_BUCKET \
  -e S3_PATH=backups \
  -e SLACK_WEBHOOK_URL=$SLACK_WEBHOOK_URL \
  -e SLACK_NOTIFY_ON_FAILURE=true \
  -e SLACK_NOTIFY_ON_WARNING=true \
  --restart=always \
  -d kontena/mongo-backup
```
