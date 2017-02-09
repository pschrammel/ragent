# frozen_string_literal: true
module Ragent
  module Logging
    def self.logger=(logger)
      @logger = logger
    end

    def self.logger
      @logger
    end

    def logger
      Ragent::Logging.logger
    end

    def debug(str)
      logger.debug(str)
  end

    def warn(str)
      logger.warn(str)
    end

    def info(str)
      logger.info(str)
    end

    def error(str)
      logger.error(str)
    end
  end
end
