# frozen_string_literal: true
require 'thread'
require 'celluloid/current'
require 'celluloid/autostart'

require 'logging'
require 'pathname'

require_relative 'ragent/version'
require_relative 'ragent/logging'
require_relative 'ragent/plugins'
require_relative 'ragent/plugin'
require_relative 'ragent/commands'
require_relative 'ragent/command'
require_relative 'ragent/configurator'
require_relative 'ragent/command_helpers'

module Ragent
  DEFAULT_LOG_LEVEL = 'info'

  def self.start(workdir: nil, log_level: nil, blocking: true)
    Ragent.setup(
      log_level: ENV['RAGENT_LOG_LEVEL'] || log_level || DEFAULT_LOG_LEVEL,
      workdir: workdir || Dir.pwd
    ).config.run(blocking)
  end

  def self.ragent
    @ragent
  end

  def self.setup(*args)
    @ragent = Agent.new(*args)
  end

  class Agent
    include Ragent::Logging

    attr_reader :workdir
    attr_reader :supervisor
    attr_reader :commands
    attr_reader :plugins

    def initialize(log_level:, workdir:)
      @workdir = Pathname.new(workdir)
      $LOAD_PATH << @workdir.join('lib').to_s

      # setup logger
      Ragent::Logging.logger = ::Logging.logger['ragent']
      logger.add_appenders ::Logging.appenders.stdout

      @commands = Ragent::Commands.new(self)
      @plugins = Plugins.new(self)

      register_commands
    end

    def config
      Ragent::Configurator.load(self, workdir.join('config.ragent'))
      self
    end

    def add_plugin(name, *args, &block)
      plugins.load(name, *args, &block) if name.is_a?(Symbol)
    end

    def run(blocking = true)
      @supervisor = Celluloid::Supervision::Container.run!
      plugins.start
      term_wait_loop if blocking
    end

    private

    def term_wait_loop
      self_read, @self_write = IO.pipe
      %w(TERM TTIN INT).each do |sig|
        Signal.trap sig do
          @self_write.puts(sig)
        end
      end
      stop = false
      while stop || readable_io = IO.select([self_read])
        signal = readable_io.first[0].gets.strip
        break if handle_signal(signal)
      end
      info 'Exiting'
    end

    #  EM.epoll
    #  Thread.new { EventMachine.run } unless EventMachine.reactor_running?
    #  sleep 0.01 until EventMachine.reactor_running?
    # end

    def handle_signal(signal)
      info "Got signal #{signal}"
      case signal
      when 'TERM', 'INT', 'SHUTDOWN' # shutdown is an internal command
        info 'Shutting down...'
        # EM.stop if EventMachine.reactor_running?
        @plugins.stop
        @supervisor.shutdown
        true
      when 'TTIN'
        Thread.list.each do |thread|
          warn "Thread #{thread.object_id.to_s(36)} #{thread['label']}"
          if thread.backtrace
            warn thread.backtrace.join("\n")
          else
            warn 'no backtrace available'
          end
        end
        false
      end
    end

    def shutdown_command(_options = {})
      @self_write.puts('SHUTDOWN')
    end

    def register_commands
      cmd = Ragent::Command.new(main: 'shutdown',
                                sub: nil,
                                recipient: self,
                                method: :shutdown_command)
      @commands.add(cmd)
    end
  end
end
