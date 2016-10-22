# encoding: utf-8

##
# Backup Generated: db_backup
# Once configured, you can run the backup with the following command:
#
# $ backup perform -t db_backup [-c <path_to_configuration_file>]
#
# For more information about Backup's components, see the documentation at:
# http://backup.github.io/backup
#
Model.new(:mongo_backup, ENV['BACKUP_NAME']) do

  ##
  # MongoDB [Database]
  #
  if ENV['MONGODB_HOST']
    database MongoDB do |db|
      db.username           = "#{ENV['MONGODB_USER']}" if ENV['MONGODB_USER']
      db.password           = "#{ENV['MONGODB_PASSWORD']}" if ENV['MONGODB_PASSWORD']
      db.host               = "#{ENV['MONGODB_HOST']}"
      if ENV['MONGODB_PORT']
        db.port             =  ENV['MONGODB_PORT']
      else
        db.port             = 27017
      end
      db.ipv6               = false
      db.additional_options = ENV['MONGODB_OPTIONS'].split(",").to_s if  ENV['MONGODB_OPTIONS']
      db.lock               = !ENV['MONGODB_LOCK'].nil?
      db.oplog              = !ENV['MONGODB_OPLOCK'].nil?
    end

  end

  ##
  # Amazon Simple Storage Service [Storage]
  #
  if ENV['S3_BUCKET']
    store_with S3 do |s3|
      # AWS Credentials
      s3.access_key_id     = "#{ENV['S3_ACCESS_KEY_ID']}"
      s3.secret_access_key = "#{ENV['S3_SECRET_ACCESS_KEY']}"
      # Or, to use a IAM Profile:
      # s3.use_iam_profile = true

      s3.region            = "#{ENV['S3_REGION']}"
      s3.bucket            = "#{ENV['S3_BUCKET']}"
      s3.path              = "#{ENV['S3_PATH']}"
      if ENV['S3_KEEP']
        s3.keep              = ENV['S3_KEEP']
      else
        s3.keep              = 30
      end
      # s3.keep              = Time.now - 2592000 # Remove all backups older than 1 month.
    end
  end

  ##
  # Dropbox [Storage]
  #
  # Your initial backup must be performed manually to authorize
  # this machine with your Dropbox account. This authorized session
  # will be stored in `cache_path` and used for subsequent backups.
  #
  if ENV['DROPBOX_PATH']
    store_with Dropbox do |db|
      db.api_key     = "#{ENV['DROPBOX_APIKEY']}"
      db.api_secret  = "#{ENV['DROPBOX_APISECRET']}"
      # Sets the path where the cached authorized session will be stored.
      # Relative paths will be relative to ~/Backup, unless the --root-path
      # is set on the command line or within your configuration file.
      db.cache_path  = ".cache"
      # :app_folder (default) or :dropbox
      db.access_type = :app_folder
      db.path        = "#{ENV['DROPBOX_PATH']}"
      if ENV['DROPBOX_KEEP']
        db.keep        =  ENV['DROPBOX_KEEP']
      else
        db.keep        = 30
      end
      # db.keep        = Time.now - 2592000 # Remove all backups older than 1 month.
    end
  end

  ##
  # RSync [Storage]
  #
  # The default `mode` is :ssh, which does not require the use
  # of an rsync daemon on the remote. If you wish to connect
  # directly to an rsync daemon, or via SSH using daemon features,
  # :rsync_daemon and :ssh_daemon modes are also available.
  #
  # If no `host` is specified, the transfer will be a local
  # operation. `mode` and `compress` will have no meaning.
  #
  if ENV['RSYNC_HOST']
    store_with RSync do |rsync|
      rsync.mode      = :ssh
      rsync.host      = "#{ENV['RSYNC_HOST']}"
      rsync.path      = "#{ENV['RSYNC_PATH']}"
      rsync.compress  = true
    end
  end

  ##
  # SFTP (Secure File Transfer Protocol) [Storage]
  #
  if ENV['SFTP_HOST']
    store_with SFTP do |server|
      server.username   = "#{ENV['SFTP_USER']}"
      server.password   = "#{ENV['SFTP_PASSWORD']}"
      server.ip         = "#{ENV['SFTP_HOST']}"
      if ENV['SFTP_PORT']
        server.port     = ENV['SFTP_PORT']
      else
        server.port     = 22
      end
      server.path       = "#{ENV['SFTP_PATH']}"
      if ENV['SFTP_KEEP']
        db.keep         = ENV['SFTP_KEEP']
      else
        db.keep         = 30
      end
      # server.keep         = Time.now - 2592000 # Remove all backups older than 1 month.

      # Additional options for the SSH connection.
      # server.ssh_options = {}
    end
  end

  ##
  # Local (Copy) [Storage]
  #
  store_with Local do |local|
    local.path       = "/backup/"
    if ENV['LOCAL_KEEP']
      local.keep     = ENV['LOCAL_KEEP']
    else
      local.keep     = 30
    # local.keep       = Time.now - 2592000 # Remove all backups older than 1 month.
    end
  end

  ##
  # Gzip [Compressor]
  #
  compress_with Gzip

  ##
  # OpenSSL [Encryptor]
  #
  if ENV['OPENSSL_PASSWORD']
    encrypt_with OpenSSL do |encryption|
      encryption.password      = "#{OPENSSL_PASSWORD}"            # From String
      encryption.base64        = true
      encryption.salt          = true
    end
  end

  if ENV['SLACK_WEBHOOK_URL']
    notify_by Slack do |slack|
      if ENV['SLACK_NOTIFY_ON_SUCCESS']
        slack.on_success = true
      end
      if ENV['SLACK_NOTIFY_ON_WARNING']
        slack.on_warning = true
      end
      if ENV['SLACK_NOTIFY_ON_FAILURE']
        slack.on_failure = true
      end

      # The integration token
      slack.webhook_url = "#{ENV['SLACK_WEBHOOK_URL']}"

      ##
      # Optional
      #
      # The channel to which messages will be sent
      slack.channel = "#{ENV['SLACK_CHANNEL']}" if ENV['SLACK_CHANNEL']

      #
      # The username to display along with the notification
      slack.username = "#{ENV['SLACK_USERNAME']}" if ENV['SLACK_USERNAME']
      #
      # The emoji icon to use for notifications.
      # See http://www.emoji-cheat-sheet.com for a list of icons.
      slack.icon_emoji = "#{ENV['SLACK_EMOJI']}" if ENV['SLACK_EMOJI']

      #
      # Change default notifier message.
      # See https://github.com/backup/backup/pull/698 for more information.
      # slack.message = lambda do |model, data|
      #   "[#{data[:status][:message]}] #{model.label} (#{model.trigger})"
      # end
    end
  end

  ##
  # Mail [Notifier]
  #
  if ENV['EMAIL_HOST']
    notify_by Mail do |mail|
      mail.on_success           = !ENV['EMAIL_NOTIFY_ON_SUCCESS'].nil?
      mail.on_warning           = !ENV['EMAIL_NOTIFY_ON_WARNING'].nil?
      mail.on_failure           = !ENV['EMAIL_NOTIFY_ON_FAILURE'].nil?

      mail.from                 = "#{ENV['EMAIL_FROM']}"
      mail.to                   = "#{ENV['EMAIL_TO']}"
      mail.address              = "#{ENV['EMAIL_HOST']}"
      mail.port                 = ENV['EMAIL_PORT']
      mail.user_name            = "#{ENV['EMAIL_USERNAME']}"
      mail.password             = "#{ENV['EMAIL_PASSWORD']}"
      mail.authentication       = 'plain'
    end
  end

  ##
  # Flowdock [Notifier]
  #
  if ENV['FLOWDOCK_TOKEN']
    notify_by FlowDock do |flowdock|
      flowdock.on_success = !ENV['FLOWDOCK_NOTIFY_ON_SUCCESS'].nil?
      flowdock.on_warning = !ENV['FLOWDOCK_NOTIFY_ON_SUCCESS'].nil?
      flowdock.on_failure = !ENV['FLOWDOCK_NOTIFY_ON_SUCCESS'].nil?
      flowdock.token      = "#{ENV['FLOWDOCK_TOKEN']}"
      flowdock.from_name  = "#{ENV['FLOWDOCK_FROM_NAME']}"
      flowdock.from_email = "#{ENV['FLOWDOCK_FROM_EMAIL']}"
      flowdock.subject    = "#{ENV['FLOWDOCK_SUBJECT']}"
      flowdock.source     = "#{ENV['FLOWDOCK_SOURCE']}"
      flowdock.tags       = ENV['FLOWDOCK_TAGS'].split(',').map{ |tag| tag.strip}.to_s if ENV['FLOWDOCK_TAGS']
      flowdock.link       = "#{ENV['FLOWDOCK_LINK']}"
    end
  end

  ##
  # Pagerduty [Notifier]
  #
  if ENV['PAGERDUTY_SERVICE_KEY']
    notify_by PagerDuty do |pagerduty|
      pagerduty.on_success = !ENV['PAGERDUTY_NOTIFY_ON_SUCCESS'].nil?
      pagerduty.on_warning = !ENV['PAGERDUTY_NOTIFY_ON_WARNING'].nil?
      pagerduty.on_failure = !ENV['FLOWDOCK_NOTIFY_ON_FAILURE'].nil?

      pagerduty.service_key = ENV['PAGERDUTY_SERVICE_KEY']
      pagerduty.resolve_on_warning = true
    end
  end

  ##
  # DataDog [Notifier]
  #
  if ENV['DATADOG_API_KEY']
    notify_by DataDog do |datadog|
      datadog.on_success           = !ENV['DATADOG_NOTIFY_ON_SUCCESS'].nil?
      datadog.on_warning           = !ENV['DATADOG_NOTIFY_ON_WARNING'].nil?
      datadog.on_failure           = !ENV['DATADOG_NOTIFY_ON_FAILURE'].nil?
      datadog.api_key              = ENV['DATADOG_API_KEY']
      datadog.host                 = ENV['DATADOG_HOST'] if ENV['DATADOG_HOST']
      datadog.tags                 = ENV['DATADOG_TAGS'].split(',').map{ |tag| tag.strip}.to_s if ENV['DATADOG_TAGS']
      datadog.alert_type           = ENV['DATADOG_ALERT_TYPE'] if ENV['DATADOG_ALERT_TYPE']
      datadog.source_type_name     = ENV['DATADOG_SOURCE_TYPE_NAME'] if ENV['DATADOG_SOURCE_TYPE_NAME']
      datadog.priority             = ENV['DATADOG_PRIORITY'] if ENV['DATADOG_PRIORITY']
      datadog.aggregation_key      = ENV['DATADOG_AGGREGATION_KEY'] if ENV['DATADOG_AGGREGATION_KEY']
    end
  end
end
