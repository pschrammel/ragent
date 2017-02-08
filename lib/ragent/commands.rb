module Ragent
  class Commands
    include Ragent::Logging

    def initialize(ragent)
      @ragent=ragent
      @commands={}
      add_help_command
    end

    def add(command)
      if command.sub?
        @commands[command.main] ||= {}
        @commands[command.main][command.sub]=command
      else
        @commands[command.main] ||= command
      end
      info "registered command: #{command.help}"
    end

    def lookup(main,sub,options)
      debug "checkig command: #{main},#{sub},#{options}"
      cmd=@commands[main]
      if cmd

        if cmd.kind_of?(Hash) && sub
          sub_cmd=@commands[main][sub]
          if sub_cmd
            debug "command found (#{main},#{sub})"
          else
            debug "command not found (#{main},#{sub})"
          end
          return sub_cmd
        else
          debug "command found (#{main})"
          return cmd
        end
      else
        debug "command not found"
      end
      nil
    end
    private

    def help_command(options={})
      @commands.values.map do |subs|
        if subs.kind_of?(Hash)
          subs.values.map do |cmd|
            cmd.help
          end
        else
          subs.help
        end
      end.flatten.join("\n")
    end

    def add_help_command
      add(Ragent::Command.new(main: 'help',
                             recipient: self,
                             method: :help_command
                            ))
    end


  end
end
