require 'yaml'
require 'logger'

module Snapshoter
  class ConfigError < Exception
  end
  
  class Config
    attr_reader :aws_public_key, :aws_private_key, :volumes
    
    def initialize(config)
      @aws_public_key = config.delete('aws_public_key')
      @aws_private_key = config.delete('aws_private_key')
      @log_file  = config.delete('log_file')
      @log_level = config.delete('log_level')
      
      @volumes = []
      
      config.keys.each do |volume_id|
        volume_options = config[volume_id]
        if volume_options.is_a? Hash
          begin
            @volumes << Snapshoter::Volume.new(volume_id, config[volume_id])
          rescue Snapshoter::VolumeInvalid => e
            raise ConfigError.new(e.message)
          end
          config.delete(volume_id)
        end
      end
      
      if config.any?
        raise ConfigError.new("Invalid config option(s) #{config.keys.map{|k| "'#{k}'"}.join(',')}")
      end
    end
    
    def logger
      @logger ||= begin
        logger = Logger.new(@log_file || STDOUT)
        logger.level = case @log_level
          when 'warn'
            Logger::WARN
          when 'error'
            Logger::ERROR
          when 'FATAL'
            Logger::FATAL
          when 'debug'
            Logger::DEBUG
          else
            Logger::INFO
          end
        logger
      end
    end
    
    def Config.read(path='/etc/snapshoter.yml')
      config = YAML.load(File.read(path))
      Config.new(config)
    end
  end
end