require 'rufus-scheduler'
$stdout.sync = true

puts '=== BACKUP WORKER ==='

backup_cmd = 'bundle exec backup perform -t mongo_backup --config-file /app/Backup/config.rb'
puts `#{backup_cmd}`

if ENV['INTERVAL']
  scheduler = Rufus::Scheduler.new
  if ENV['INTERVAL'].match(" ")
    scheduler.cron ENV['INTERVAL'] do
      puts `#{backup_cmd}`
    end
  else
    scheduler.every ENV['INTERVAL'] do
      puts `#{backup_cmd}`
    end
  end
  scheduler.join
end
