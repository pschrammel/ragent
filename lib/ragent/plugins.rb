# frozen_string_literal: true
# Ragent::Plugin is reserved for plugins!
module Ragent
  class Plugins
    include Ragent::Logging

    def initialize(ragent)
      @ragent = ragent
      @logger = ragent.logger
      @plugins = {}
      @running_plugins = []
    end

    def load(name, *args, &block)
      info "loading plugin #{name}"
      require "ragent/plugin/#{name}"
      raise "plugin #{name} didn't register" unless @plugins[name.to_s]
      info "loaded plugin #{name}"
      # TODO: load and configure dependencies
      plugin = @plugins[name.to_s]
      info "Configure: #{name}"
      running_plugin = plugin.new(@ragent,plugin_name: name)
      running_plugin.configure(*args, &block)
      debug "Configured: #{name}"
      @running_plugins << running_plugin
    end

    def register(mod)
      @plugins[mod.plugin_name] = mod
    end

    def start
      @running_plugins.each do |plugin|
        info "Starting: #{plugin.plugin_name}"
        plugin.start
        debug "Started: #{plugin.plugin_name}"
      end
    end

    def stop
      @running_plugins.each do |plugin|
        info "Stopping: #{plugin.plugin_name}"
        plugin.stop
        debug "Stopped: #{plugin.plugin_name}"
      end
    end

    private

    def register_commands
      # stop
      cmd = Ragent::Command.new(main: 'plugins',
                                sub: 'list',
                                recipient: self,
                                method: :plugins_list_command)
      @ragent.commands.add(cmd)
    end

    def plugins_list_command(_options)
      @plugins.values.map(&:name).join("\n")
    end
  end
end
