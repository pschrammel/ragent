class TimeBomb

  class TestBomb
    include Celluloid
    include Celluloid::Notifications
    def initialize
      async.start
    end


    def start
      while true do
        sleep 5
        puts "Boom! #{Time.now}"
      end
    end

    def stop

    end
  end


  include Ragent::Logging

  def initialize(ragent)
    @ragent=ragent
    @logger=ragent.logger
  end

  def configure
    info "configuring TimeBomb"
    command("tick", :command_tick)
  end

  def start
  end

  def stop
  end

  def name
    'time-bomb'
  end

  def command(sub, method)
    cmd=Ragent::Command.new(main: name,
                             sub: sub,
                             recipient: self,
                             method: method)
    @ragent.commands.add(cmd)
  end

  def command_tick
    @ragent.supervisor.supervise(
      type: TimeBomb::TestBomb,
      as: :time_bomb
    )
    "starting timebomb"
  end
end
