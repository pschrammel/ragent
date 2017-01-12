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

    def load(name)
      info "loading plugin #{name}"
      require "ragent/plugin/#{name}"
      raise "plugin #{name} didn't register" unless @plugins[name.to_s]
    end
    
    def register(name, mod)
      @plugins[name.to_s] = mod
    end

    def configure
      @plugins.values.each do |plugin|
        info "Configure: #{plugin.name}"
        running_plugin=plugin.new(@ragent)
        running_plugin.configure
        @running_plugins << running_plugin
      end
      self
    end

    def start
      @running_plugins.each do |plugin|
        info "Starting: #{plugin.name}"

        plugin.start
      end
    end

    def stop
      @running_plugins.each do |plugin|
        info "Stoping: #{plugin.name}"
        plugin.stop
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
