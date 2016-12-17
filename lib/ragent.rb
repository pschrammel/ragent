require 'faye/websocket'
require 'eventmachine'
require 'thread'
require 'celluloid/current'
require 'celluloid/autostart'

require 'active_support/inflector'

require 'logging'
require 'pathname'

require_relative 'ragent/logging'
require_relative 'ragent/plugins'
require_relative 'ragent/commands'
require_relative 'ragent/command'

module Ragent
  def self.start(*args)
    Agent.new(*args).run
  end

  class Agent
    include Ragent::Logging

    attr_reader :supervisor, :workdir
    attr_reader :commands
    def initialize(log_level:, workdir:)
      @workdir=Pathname.new(workdir)


      Ragent::Logging.logger=::Logging.logger['ragent']
      logger.add_appenders ::Logging.appenders.stdout

      @commands=Ragent::Commands.new(self)
      register_commands

      @plugins=Plugins.search(self)
      @plugins.configure
      @supervisor = Celluloid::Supervision::Container.run!
    end

    def run
      self_read, @self_write = IO.pipe

      %w(TERM TTIN INT).each do |sig|
        Signal.trap sig do
          @self_write.puts(sig)
        end
      end

      #start_em
      @plugins.start

      stop=false
      while stop || readable_io = IO.select([self_read])
        signal = readable_io.first[0].gets.strip
        stop=handle_signal(signal)
        exit(0)
      end
    end

    private

    def start_em
      EM.epoll
      Thread.new { EventMachine.run } unless EventMachine.reactor_running?
      sleep 0.01 until EventMachine.reactor_running?
    end

    def handle_signal(signal)
      info "Got signal #{signal}"
      case signal
      when 'TERM','INT'
        info "Shutting down..."
        EM.stop if EventMachine.reactor_running?
        @plugins.stop
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


    def stop_command
      @self_write.puts("TERM")
    end

    def register_commands
      # stop
      cmd=Ragent::Command.new(main: 'stop',
                              sub: nil,
                              recipient: self,
                              method: :stop_command)
      @commands.add(cmd)
    end
  end
end
