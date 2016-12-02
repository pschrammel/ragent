require 'faye/websocket'
require 'eventmachine'
require 'thread'
require 'celluloid/current'
require 'celluloid/autostart'

require 'active_support/inflector'

require 'logging'
require 'pathname'

require_relative 'ragent/logging'

module Ragent
  def self.start(*args)
    Agent.new(*args).run
  end

  class Agent
    include Ragent::Logging

    attr_reader :supervisor, :logger
    def initialize(log_level:, workdir:)
      @workdir=Pathname.new(workdir)
      @plugins={}
      @logger=::Logging.logger['ragent']
      @logger.add_appenders ::Logging.appenders.stdout
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
      # find plugins
      plugins_dir=@workdir.join("plugins").expand_path
      plugins_dir.
        each_child(false) do |plugin_dir|
        require plugins_dir.join(plugin_dir,'ragent.rb').to_s
        plugin=ActiveSupport::Inflector.
                constantize(
                  ActiveSupport::Inflector.camelize(
                  plugin_dir)).new(self)
        @plugins[plugin_dir]=plugin
        info "found plugin #{plugin.name}"
        plugin.configure
      end
      # call initialize
    end

    def start_plugins
      info "Start plugins"
      @plugins.values.each do |plugin|
        plugin.start
      end

    end

  end


end
