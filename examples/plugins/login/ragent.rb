require 'celluloid/current'
require 'celluloid/io'


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
    'Login'
  end

  private
  def run
    loop { async.handle_connection @server.accept}
  end

  def handle_connection(socket)
    _, port, host = socket.peeraddr
    info "connection from #{host}:#{port}"
    loop { socket.write socket.readpartial(4096)}
  rescue EOFError
    info "disconnected"
    socket.close
  end
end
