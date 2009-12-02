require 'right_aws'

module Snapshoter
  module Provider
    class EC2Provider
      def initialize(config)
        @config = config
      end
    
      # Returns the most recent time a snapshot was started for a given volume or nil if there are none
      def last_snapshot_at(volume)
        snapshots = snapshots_by_volume_id(volume.id)
        snapshots.any? ? snapshots.first[:aws_started_at] : nil
      end
    
      def snapshot_volume(volume)
        logger.info "[Volume #{volume.id}] Snapshot started"
        if ec2.create_snapshot(volume.id)
          logger.info "[Volume #{volume.id}] Snapshot complete"
        else
          logger.error "[Volume #{volume.id}] Snapshot failed!"
        end
      end
    
      def delete_old_snapshots(volume)
        deleted_count = 0
        old_snapshots = snapshots_by_volume_id(volume.id)[volume.keep..-1]
        if old_snapshots && old_snapshots.any?
          logger.info "[Volume #{volume.id}] Deleting #{old_snapshots.length} old snapshots for #{volume.id}"
          old_snapshots.each do |snapshot|
            if snapshot[:aws_status] == 'completed'
              logger.debug "[Volume #{volume.id}][Snapshot #{snapshot[:aws_id]}] Deleting snapshot created on #{snapshot[:aws_started_at]} #{snapshot[:aws_id]}"
              if ec2.delete_snapshot(snapshot[:aws_id])
                deleted_count += 1
                logger.debug "[Volume #{volume.id}][Snapshot #{snapshot[:aws_id]}] Snapshot deleted"
              else
                logger.error "[Volume #{volume.id}][Snapshot #{snapshot.id}] Snapshot delete failed!"
              end
            else
              logger.info "[Volume #{volume.id}][Snapshot #{snapshot.id}] Could not be deleted because status is '#{snapshot[:aws_status]}'"
            end
          end
        else
          logger.debug "[Volume #{volume.id}] No old snapshots to delete"
        end
        deleted_count
      end
    
      def refresh
        snapshots(true) if @snapshots
      end
      
    private
  
      def logger
        @config.logger
      end
  
      def snapshots_by_volume_id(volume_id)
        snapshots.select {|s| s[:aws_volume_id] == volume_id}.sort_by{|s| s[:aws_started_at]}.reverse
      end
  
      def snapshots(refresh=false)
        if @snapshots && !refresh
          @snapshots
        else
          @snapshots = ec2.describe_snapshots
        end
      end
    
      def ec2
        @ec2 ||= RightAws::Ec2.new(@config.aws_public_key, @config.aws_private_key)
      end
    end
  end
end