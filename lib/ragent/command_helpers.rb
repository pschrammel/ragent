# frozen_string_literal: true
module Ragent
  module CommandHelpers
    def command(*commands)
      @prepared_commands = []
      commands.each do |command|
        prep_command = { main: plugin_name, # name of the plugin
                         sub: command,
                         method: "command_#{command}" }
        @prepared_commands << prep_command
      end
    end

    def prepared_commands
      @prepared_commands || []
    end

    alias commands command
  end
end
