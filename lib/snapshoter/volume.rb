module Snapshoter
  class VolumeInvalid < Exception
    def initialize(id, errors)
      @id = id
      @errors = errors
    end

    def message
      "Error with configuration of volume #{@id || '<unknown>'}:\n  #{@errors.join("\n  ")}\n"
    end
  end
  
  class Volume
    ValidFrequencies = [:hourly, :daily, :weekly]
    
    attr_reader :id, :mount_point, :frequency, :freeze_mysql, :mysql_user, :mysql_password, :mysql_port, :mysql_sock, :keep
    
    def initialize(volume_id, options={})
      options = options.symbolize_keys
      
      @id = volume_id
      @mount_point = options.delete(:mount_point)
      @frequency = options.delete(:frequency) || 'daily'
      @freeze_mysql = options.delete(:freeze_mysql) || false
      @mysql_user = options.delete(:mysql_user) || 'root'
      @mysql_password = options.delete(:mysql_password)
      @mysql_port = options.delete(:mysql_port) 
      @mysql_sock = options.delete(:mysql_sock) 
      @keep = options.delete(:keep) || 7
      
      @frequency = @frequency.to_sym
      
      validate!(options)
    end
    
    def to_s
      "##{@id}"
    end
    
  private
  
    def validate!(extra_options)
      errors = []
      
      errors << 'volume must have an id' if @id.nil?
      errors << "frequency must be one of #{ValidFrequencies.join(",")}" unless ValidFrequencies.include?(@frequency)
      errors << 'mount_point must be specified' if @mount_point.nil?
      errors << 'freeze_mysql must be true or false' if @freeze_mysql != true && @freeze_mysql != false
      errors << "keep must be greater than 0" if keep <= 0
      
      extra_options.keys.each do |key|
        errors << "unknown volume attribute #{key}"
      end
            
      if errors.any?
        raise VolumeInvalid.new(@id, errors)
      end
    end
    
  end
end