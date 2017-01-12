require 'celluloid/current'
require 'celluloid/io'


module Ragent
 module Plugin
class Login

  include Ragent::Logging

  include Celluloid::IO
  finalizer :stop

  def initialize(ragent)
    @ragent=ragent
    @logger=ragent.logger
  end

  def configure
    @server=TCPServer.new('127.0.0.1', 6666)
  end

  def start
    async.run
  end

  def stop
    @server.close if @server
  end

  def name
    'login'
  end

  private
  def run
    loop { async.handle_connection @server.accept}
  end

  def handle_connection(socket)
    _, port, host = socket.peeraddr
    info "connection from #{host}:#{port}"
    looping=true
    while looping do
      line=socket.readpartial(4096)
      if line.strip=='exit'
        socket.puts "exiting"
        looping=false
      elsif cmd=@ragent.commands.match(line)
        socket.puts cmd.execute
      else
        socket.puts "unknown command: #{line}"
      end
    end
    socket.close
  rescue EOFError
    info "disconnected"
    socket.close
  end

end

end
end

Ragent.ragent.plugins.register('login', Ragent::Plugin::Login)
