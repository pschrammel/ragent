module Ragent
  module Plugin
    def self.included(klass)
      klass.send(:include, Ragent::Logging)
      klass.send(:include, Celluloid)
      klass.send(:include, Celluloid::Notifications)
      klass.send(:finalizer, :stop)
      def initialize(ragent)
        @ragent = ragent
        @logger = ragent.logger
      end

      def configure(*args, &block)
      end

      def stop
      end
    end


  end

end
