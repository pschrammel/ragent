# frozen_string_literal: true
module Ragent
  module Plugin
    class TimeBomb
      class Bomb
        include Celluloid
        include Celluloid::Notifications
        include Ragent::Logging

        finalizer :stop

        def initialize
          async.start
        end

        def start
          every(5) do
            publish 'time-bomb-boom', expode_at: Time.now
          end
        end

        def stop
          info 'disarmed'
        end
      end
    end
  end
end
