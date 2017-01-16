# Ragent::Plugin is reserved for plugins!
module Ragent
  class Plugins
    include Ragent::Logging

    def initialize(ragent)
      @ragent=ragent
      @logger=ragent.logger
      @plugins={}
      @running_plugins=[]
    end

    def load(name,*args, &block)
      info "loading plugin #{name}"
      require "ragent/plugin/#{name}"
      raise "plugin #{name} didn't register" unless @plugins[name.to_s]
      info "loaded plugin #{name}"
      #TODO: load and configure dependencies
      plugin=@plugins[name.to_s]
      info "Configure: #{plugin.name}"
      running_plugin=plugin.new(@ragent)
      running_plugin.configure(*args, &block)
      debug "Configured: #{plugin.name}"
      @running_plugins << running_plugin
    end

    def register(name, mod)
      @plugins[name.to_s] = mod
    end

    def start
      @running_plugins.each do |plugin|
        info "Starting: #{plugin.name}"
        # TODO: start dependencies
        plugin.start
        debug "Started: #{plugin.name}"
      end
    end

    def stop
      @running_plugins.each do |plugin|
        info "Stopping: #{plugin.name}"
        plugin.stop
        debug "Stopped: #{plugin.name}"
      end
    end

    private

    def register_commands
      # stop
      cmd=Ragent::Command.new(main: 'plugins',
                              sub: 'list',
                              recipient: self,
                              method: :plugins_list_command)
      @ragent.commands.add(cmd)
    end

    def plugins_list_command(options)
      @plugins.values.map do |plugin| plugin.name end.join("\n")
    end
  end
end
