require 'mysql'

module Snapshoter
  class Manager
    def initialize(config, provider)
      @config = config
      @provider = provider
    end
    
    def run
      # ensure we have the latest snapshot data
      @provider.refresh
      
      # First create all the snapshots
      @config.volumes.each do |volume|
        if should_take_snapshot(volume)
          if volume.freeze_mysql
            mysql = Mysql.connect(
                    'localhost',
                    volume.mysql_user, 
                    volume.mysql_password,
                    volume.mysql_port,
                    volume.mysql_sock)
          else
            mysql = nil
          end
        
          logger.debug "[Volume #{volume}] Starting snapshot"
          success = false
          begin
            lock_mysql(mysql) if mysql
            freeze_xfs(volume.mount_point)
            @provider.snapshot_volume(volume)
          rescue Exception => e
            logger.error "[Volume #{volume}] There was a problem creating snapshot!"
            logger.error e.message
            logger.error e.backtrace.join("\n")
          ensure
            unfreeze_xfs(volume.mount_point)
            if mysql
              unlock_mysql(mysql)
              mysql.close
            end
          end
        end
      end
      
      # ensure we have the latest snapshot data
      @provider.refresh
      
      # Then cleanup old snapshots
      @config.volumes.each do |volume|
        delete_old_snapshots(volume)
      end
    end
    
  private
  
    def logger
      @config.logger
    end
    
    def freeze_xfs(mount_point)
      logger.debug "Freezing filesystem at #{mount_point}"
      `xfs_freeze -f #{mount_point}`
      logger.debug "Filesystem frozen at #{mount_point}"
    end
    
    def unfreeze_xfs(mount_point)
      logger.debug "unfreezing xfs on mount point #{mount_point}"
      `xfs_freeze -u #{mount_point}`
    end
  
    def lock_mysql(mysql)
      logger.debug "locking mysql tables"
      mysql.query "FLUSH TABLES WITH READ LOCK"
      # TODO: capture mysql master bin log position and log it somewhere
    end
    
    def unlock_mysql(mysql)
      logger.debug  "unfreezing mysql"
      mysql.query   "UNLOCK TABLES"
    end
    
    def delete_old_snapshots(volume)
      logger.debug "Deleting old snapshots of volume #{volume}"
      begin
        n = @provider.delete_old_snapshots(volume)
        logger.info "[Volume #{volume}] Deleted #{n} old snapshots" if n > 0
      rescue Exception => e
        logger.error "[Volume #{volume}] There was a problem deleting old snaphots"
        logger.error e.message
        logger.error e.backtrace.join("\n")
      end
    end
    
    def should_take_snapshot(volume)
      if last_snapshot_at = @provider.last_snapshot_at(volume)
        
        last = last_snapshot_at.localtime
        now  = Time.now
        
        if volume.frequency == :hourly
          time_of_last_snapshot = seconds_to_hours(last)
          current_time          = seconds_to_hours(now)
        elsif volume.frequency == :daily
          time_of_last_snapshot = seconds_to_days(last)
          current_time          = seconds_to_days(now)
        elsif volume.frequency == :weekly
          time_of_last_snapshot = seconds_to_weeks(last)
          current_time          = seconds_to_weeks(now)
        else
          raise "Unknown frequency #{volume.frequency}"
        end
        
        time_of_last_snapshot != current_time
      else
        true
      end
    end
    
    def seconds_to_hours(s)
      s.strftime("%Y%m%d%H")
    end
    
    def seconds_to_days(s)
      s.strftime("%Y%m%d")
    end
    
    def seconds_to_weeks(s)
      s.strftime("%Y%m") + ((s.day - 1) / 7).to_s
    end
  end
end