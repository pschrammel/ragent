# frozen_string_literal: true
require 'celluloid/current'
require 'celluloid/io'

module Ragent
  module Plugin
    class Login
      include Ragent::Plugin
      include Celluloid::IO

      plugin_name 'login'

      def start
        @server = TCPServer.new('127.0.0.1', 6666)
        async.run
      end

      def stop
        @server&.close
      end

      private

      def run
        loop { async.handle_connection @server.accept }
      end

      def handle_connection(socket)
        _, port, host = socket.peeraddr
        info "connection from #{host}:#{port}"
        looping = true
        while looping
          line = socket.readpartial(4096)
          if line.strip == 'exit'
            socket.puts 'exiting'
            looping = false
          else
            cmd, options = parse_line(line)
            if cmd
              socket.puts cmd.execute(options)
            else
              socket.puts "unknown command: #{line}"
            end
          end
        end
        socket.close
      rescue EOFError
        info 'disconnected'
        socket.close
      end

      def parse_line(line)
        words = line.split(' ')
        # do we have a sub?
        main_command = words.shift
        sub_command = nil
        sub_command = words.shift if !words.empty? && words[0][0] != '-'
        options = parse_options(words)
        cmd = @ragent.commands.lookup(main_command, sub_command, options)
        if cmd
          return cmd, options
        else
          return nil, nil
        end
      end

      # currently we parse everything into a hash
      # (ignoring the first two char - should be --)
      #
      def parse_options(words)
        words.each_slice(2).to_a.map do |key, value|
          [key[2..-1], value]
        end.to_h
      end
    end
 end
end

Ragent.ragent.plugins.register(Ragent::Plugin::Login)
