module Ragent
  class Commands
    include Ragent::Logging

    def initialize(ragent)
      @ragent=ragent
      @commands={}
      add_help_command
    end

    def add(command)
      if command.sub
        @commands[command.main] ||= {}
        @commands[command.main][command.sub]=command
      else
        @commands[command.main] ||= command
      end
      info "registered command: #{command.help}"
    end

    def match(line)
      words=line.split(" ")

      case words.length
      when 1
        cmd=@commands[words[0]]
        #got a main hit
        if cmd
          if cmd.kind_of?(Hash)
            return nil # no exact match (yet)
          else # full hit
            return cmd
          end
        end
      when 2
        cmd=@commands[words[0]]
        if cmd
          if cmd.kind_of?(Hash)
            subcmd=cmd[words[1]]
            return subcmd
          else
            return cmd
          end
        end
      end

      nil
    end


    private

    def help_command
      "I'd like to help you!"
    end

    def add_help_command
      add(Ragent::Command.new(main: 'help',
                             recipient: self,
                             method: :help_command
                            ))
    end
  end
end
