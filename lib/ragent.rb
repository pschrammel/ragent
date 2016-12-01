require 'faye/websocket'
require 'eventmachine'
require 'thread'
require 'celluloid/current'
require 'celluloid/autostart'

require 'logging'



module Ragent
  def self.start(options)
    Agent.new(options).run
  end

  class Agent
    def warn str
      @logger.warn(str)
    end

    def info str
      @logger.info(str)
    end


    def initialize(options)
      @logger=Logging.logger['ragent']
      @logger.add_appenders Logging.appenders.stdout
      @queue = Queue.new
      #@client = Kontena::WebsocketClient.new(@opts[:api_uri], @opts[:api_token])
      @supervisor = Celluloid::Supervision::Container.run!
      initialize_plugins
    end

    def connect!
      start_em
    #  @client.ensure_connect
    end

    def start_em
      EM.epoll
      Thread.new { EventMachine.run } unless EventMachine.reactor_running?
      sleep 0.01 until EventMachine.reactor_running?
    end

    def run
      self_read, self_write = IO.pipe

      %w(TERM TTIN INT).each do |sig|
        Signal.trap sig do
          self_write.puts(sig)
        end
      end

      connect!
      start_plugins
      stop=false
      while stop || readable_io = IO.select([self_read])
        signal = readable_io.first[0].gets.strip
        stop=handle_signal(signal)
        exit(0)
      end
    end

    def handle_signal(signal)
      info "Got signal #{signal}"
      case signal
      when 'TERM','INT'
        info "Shutting down..."
        EM.stop
        @supervisor.shutdown
        true
      when 'TTIN'
        Thread.list.each do |thread|
          warn "Thread #{thread.object_id.to_s(36)} #{thread['label']}"
          if thread.backtrace
            warn thread.backtrace.join("\n")
          else
            warn "no backtrace available"
          end
        end
        false
      end
    end

    def initialize_plugins
      puts "init plugins"
    end

    def start_plugins
      puts "start_plugins"
      @supervisor.supervise(
        type: Ragent::Test,
        as: :the_time
      )
      @supervisor.supervise(
        type: Ragent::Test,
        as: :the_time2
      )
    end

  end

  class Test
    include Celluloid
    include Celluloid::Notifications
    def initialize
      async.start
    end

    def start
      while true do
        puts Time.now
        sleep 5
      end
    end
    def stop

    end
  end
end
